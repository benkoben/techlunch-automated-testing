package tests

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/google/go-cmp/cmp"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/hashicorp/terraform-exec/tfexec"
)

func network(t *testing.T) *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../../terraform-azurerm-network-isolated",
		Reconfigure:  true,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"location":                      "westeurope",
			"virtual_network_name":          "integration-test-vnet",
			"virtual_network_address_space": []string{"192.168.0.0/16"},
			"nat_gateway_name":              "integration-test-natgw",
			"public_ip_name":                "integration-test-pip",
			"resource_group_name":           "integration-test-rg",
		},
	}
}

// Returns a mock configuration for a public AKS cluster
func publicAksCluster(t *testing.T) *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../.",
		Reconfigure:  true,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"resource_group_name":                  "rg-aks-test-euw",
			"name":                                 "aks-modtest-dev-euw",
			"node_resource_group_name":             "nodepool01",
			"dns_prefix":                           "aks-module-test",
			"sku_tier":                             "Free",
			"allowed_ip_address_ranges":            []string{},
			"oidc_issuer_enabled":                  true,
			"virtual_network_id":                   "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/TestResourceGroup/providers/Microsoft.Network/virtualNetworks/MyVirtualNetwork1",
			"subnet_name":                          "aks-snet-blue",
			"subnet_address_prefix":                "192.168.0.0/24",
			"user_managed_nat_gateway_resource_id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/natgateway_test/providers/Microsoft.Network/natGateways/nat_gateway",
			"aks_identity_type":                    "UserAssigned",
			"kubelet_identity_name":                "mi-kubelet-aks-mod-dev-blue-euw",
			"private_cluster_enabled":              false,
			"admin_username":                       "dummyadmin",
			"create_dns_zones":                     false,
			"network_profile": map[string]interface{}{
				"network_plugin":      "azure",
				"outbound_type":       "userAssignedNATGateway",
				"network_policy":      "calico",
				"network_plugin_mode": "overlay",
				"load_balancer_sku":   "standard",
				"service_cidr":        "192.168.100.0/23",
				"dns_service_ip":      "192.168.101.254",
				"docker_bridge_cidr":  "172.16.0.0/12",
				"load_balancer_profile": map[string]int{
					"managed_outbound_ip_count": 1,
				},
				"nat_gateway_profile": map[string]int{
					"idle_timeout_in_minutes": 10,
				},
			},
			"default_node_pool": map[string]interface{}{
				"vm_size":                "Standard_DS2_v2",
				"node_count":             1,
				"enable_auto_scaling":    false,
				"max_pods":               35,
				"enable_host_encryption": false,
			},
			"node_pools": []map[string]interface{}{
				{
					"name":       "internal",
					"vm_size":    "Standard_DS2_v2",
					"node_count": 1,
					"max_pods":   35,
				},
			},
		},
	}
}

func TestUT_AksCluster(t *testing.T) {
	// Lets Unit tests run in parallel
	t.Parallel()

	// Table driven tests
	tests := []struct {
		name    string
		input   *terraform.Options
		want    []string
		options struct {
			planOut string
		}
	}{
		{
			name:  "basic-public-cluster",
			input: publicAksCluster(t),
			want: []string{
				"azurerm_kubernetes_cluster.aks",
				"azurerm_kubernetes_cluster_node_pool.aks[\"internal\"]",
				"azurerm_resource_group.aks",
				"azurerm_role_assignment.aks[0]",
				"azurerm_role_assignment.network_contributor[0]",
				"azurerm_subnet.aks",
				"azurerm_subnet_nat_gateway_association.aks",
				"azurerm_user_assigned_identity.aks[0]",
				"azurerm_user_assigned_identity.kubelet[0]",
				"tls_private_key.aks",
			},
			options: struct{ planOut string }{
				planOut: "basic-public-cluster.tfplan",
			},
		},
	}

	for _, test := range tests {
		// Runs each test in the tests table as a subset of the unit test.
		// Each test is run as an individual goroutine.
		provider, err := NewProvider(test.input.TerraformDir + "/provider.tf")
		if err != nil {
			t.Fatal(err)
		}

		provider.Create()

		t.Run(test.name, func(t *testing.T) {
			tf, err := tfexec.NewTerraform(test.input.TerraformDir, LocateTerraformExec())
			if err != nil {
				t.Fatal(err)
			}
			terraform.Init(t, test.input)

			// Run
			validateJson, err := tf.Validate(context.Background())
			if err != nil {
				t.Fatal(err)
			}

			if !validateJson.Valid || validateJson.WarningCount > 0 || validateJson.ErrorCount > 0 {
				for _, diagnostic := range validateJson.Diagnostics {
					msg, err := json.Marshal(diagnostic)
					if err != nil {
						t.Fatal(err)
					}
					t.Log(fmt.Printf("%s", msg))
				}
				t.Fatalf("configuration is not valid")
			}

			// Create plan outfile
			_, err = terraform.RunTerraformCommandE(t, test.input, terraform.FormatArgs(test.input, "plan", "-out="+test.options.planOut)...)
			if err != nil {
				t.Fatal(err)
			}

			// Read plan file as json
			planJson, err := tf.ShowPlanFile(context.Background(), test.options.planOut)
			if err != nil {
				t.Fatal(err)
			}
			got := ParseResourceAddresses(planJson)

			if diff := cmp.Diff(test.want, got); diff != "" {
				t.Fatalf("%s = Unexpected result, (-want, +got)\n%s\n", test.name, diff)
			}
		})
	}
}

func TestIT_AksCluster(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name  string
		input []*terraform.Options
	}{
		{
			name:  "basic-public-cluster",
			input: []*terraform.Options{network(t), publicAksCluster(t)},
		},
	}

	for _, test := range tests {

		t.Run(test.name, func(t *testing.T) {

			// Create provider.tf files in each module involved in this test
			networkProvider, err := NewProvider(test.input[0].TerraformDir + "/provider.tf")
			if err != nil {
				t.Fatal(err)
			}
			defer networkProvider.Delete()
			networkProvider.Create()

			aksProvider, err := NewProvider(test.input[1].TerraformDir + "/provider.tf")
			if err != nil {
				t.Fatal(err)
			}
			defer aksProvider.Delete()
			aksProvider.Create()

			var networkModuleOutput string
			var aksModuleInput map[string]interface{}

			// Deploy network resources
			defer terraform.Destroy(t, test.input[0])
			terraform.InitAndApply(t, test.input[0])

			// Fetch output from network module
			networkModuleOutput = terraform.OutputJson(t, test.input[0], "")
			err = json.Unmarshal([]byte(networkModuleOutput), &aksModuleInput)
			if err != nil {
				t.Fatal("error - could not unmarshal output from dependencies deployment")
			}

			// Parse network module output
			vnetId := aksModuleInput["vnet_id"].(map[string]interface{})["value"].(string)
			natGwId := aksModuleInput["nat_gateway_id"].(map[string]interface{})["value"].(string)

			// Replace mock values with the values parsed from the network module
			test.input[1].Vars["virtual_network_id"] = vnetId
			test.input[1].Vars["user_managed_nat_gateway_resource_id"] = natGwId

			// Deploy AKS to network
			defer terraform.Destroy(t, test.input[1])
			terraform.Init(t, test.input[1])
			terraform.ApplyAndIdempotent(t, test.input[1])

		})
	}
}
