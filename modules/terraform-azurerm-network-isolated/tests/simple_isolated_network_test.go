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

func mockSimpleIsolatedNetworkEun(t *testing.T) *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../.",
		Reconfigure:  true,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"location":                      "northeurope",
			"resource_group_name":           "rg-test-network-isolated-simple-eun",
			"virtual_network_name":          "vnet-test-network-isolated-simple-eun",
			"virtual_network_address_space": []string{"10.0.0.0/24"},
			"nat_gateway_name":              "ngw-test-network-isolated-simple-eun",
			"public_ip_name":                "pip-test-network-isolated-simple-eun",
		},
	}
}
func mockSimpleIsolatedNetwork(t *testing.T) *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../.",
		Reconfigure:  true,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"location":                      "westeurope",
			"resource_group_name":           "rg-test-network-isolated-simple-euw",
			"virtual_network_name":          "vnet-test-network-isolated-simple-euw",
			"virtual_network_address_space": []string{"10.0.0.0/24"},
			"nat_gateway_name":              "ngw-test-network-isolated-simple-euw",
			"public_ip_name":                "pip-test-network-isolated-simple-euw",
		},
	}
}

func mockIsolatedNetworkWithIpPrefixes(t *testing.T) *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../.",
		Reconfigure:  true,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"location":                      "westeurope",
			"resource_group_name":           "rg-test-network-isolated-prefixes-euw",
			"virtual_network_name":          "vnet-test-network-isolated-prefixes-euw",
			"virtual_network_address_space": []string{"10.0.0.0/24"},
			"nat_gateway_name":              "ngw-test-network-isolated-prefixes-euw",
			"public_ip_name":                "pip-test-network-isolated-prefixes-euw",
			"public_ip_prefixes": []map[string]string{
				{
					"name":          "pip-1",
					"prefix_length": "30",
				},
				{
					"name":          "pip-2",
					"prefix_length": "28",
				},
			},
		},
	}
}

func TestUT_NetworkIsolated(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		input   *terraform.Options
		want    []string
		options struct {
			planOut string
		}
	}{		{
			name:  "simple-isolated-network-eun",
			input: mockSimpleIsolatedNetworkEun(t),
			// The order of the elements is important
			// Tip: Run a test to see the order of the resources
			want: []string{
				"azurerm_nat_gateway.main",
				"azurerm_nat_gateway_public_ip_association.main",
				"azurerm_public_ip.main",
				"azurerm_resource_group.main",
				"azurerm_virtual_network.main",
			},
			options: struct{ planOut string }{
				planOut: "simple-isolated-network-eun.tfplan",
			},
		},
		{
			name:  "simple-isolated-network",
			input: mockSimpleIsolatedNetwork(t),
			// The order of the elements is important
			// Tip: Run a test to see the order of the resources
			want: []string{
				"azurerm_nat_gateway.main",
				"azurerm_nat_gateway_public_ip_association.main",
				"azurerm_public_ip.main",
				"azurerm_resource_group.main",
				"azurerm_virtual_network.main",
			},
			options: struct{ planOut string }{
				planOut: "simple-isolated-network.tfplan",
			},
		},
		{
			name:  "isolated-network-with-ip-prefixes",
			input: mockIsolatedNetworkWithIpPrefixes(t),
			// The order of the elements is important
			// Tip: Run a test to see the order of the resources
			want: []string{
				"azurerm_nat_gateway.main",
				"azurerm_nat_gateway_public_ip_association.main",
				"azurerm_public_ip.main",
				"azurerm_public_ip_prefix.main[\"pip-1\"]",
				"azurerm_public_ip_prefix.main[\"pip-2\"]",
				"azurerm_resource_group.main",
				"azurerm_virtual_network.main",
			},
			options: struct{ planOut string }{
				planOut: "isolated-network-with-ip-prefixes.tfplan",
			},
		},
	}

	for _, test := range tests {
		// Runs each test in the tests table as a subset of the unit test.
		// Each test is run as an individual goroutine.
		t.Run(test.name, func(t *testing.T) {
			tf, err := tfexec.NewTerraform(test.input.TerraformDir, locateTerraformExec())
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
			got := parseResourceAddresses(planJson)

			if diff := cmp.Diff(test.want, got); diff != "" {
				t.Fatalf("%s = Unexpected result, (-want, +got)\n%s\n", test.name, diff)
			}
		})
	}
}

func TestIT_NetworkIsolated(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name  string
		input []*terraform.Options
	}{
		{
			name:  "simple-isolated-network",
			input: []*terraform.Options{mockSimpleIsolatedNetwork(t)},
		},
		{
			name:  "isolated-network-with-ip-prefixes",
			input: []*terraform.Options{mockIsolatedNetworkWithIpPrefixes(t)},
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			defer terraform.Destroy(t, test.input[0])
			terraform.Init(t, test.input[0])
			terraform.ApplyAndIdempotent(t, test.input[0])
		})
	}
}
