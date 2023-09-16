package tests

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/hashicorp/terraform-exec/tfexec"
)

// Returns a mock configuration for a public AKS cluster
func publicSharedServices(t *testing.T) *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../.",
		Reconfigure:  true,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"location":            "westeurope",
			"resource_group_name": "rg-shared-services-test",
			"container_registry": map[string]interface{}{
				"create":        true,
				"name":          "testacr0915",
				"sku":           "Standard",
				"admin_enabled": false, // Perhaps we should enable this for pushing a container during the test
			},
			"keyvault": map[string]interface{}{
				"create":                        true,
				"name":                          "testkeyv0915",
				"sku_name":                      "standard",
				"public_network_access_enabled": true,
			},
			"enable_private_networking": false,
			"create_dns_zones":          false,
		},
	}
}

func TestUT_PublicSharedServices(t *testing.T) {
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
			name:  "public-shared-services",
			input: publicSharedServices(t),
			want:  []string{},
			options: struct{ planOut string }{
				planOut: "public-shared-services.tfplan",
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
		defer provider.Delete()
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
			// planJson, err := tf.ShowPlanFile(context.Background(), test.options.planOut)
			// if err != nil {
			// 	t.Fatal(err)
			// }
			// got := ParseResourceAddresses(planJson)

			// if diff := cmp.Diff(test.want, got); diff != "" {
			// 	t.Fatalf("%s = Unexpected result, (-want, +got)\n%s\n", test.name, diff)
			// }
		})
	}
}

// func TestIT_AksCluster(t *testing.T) {
// 	t.Parallel()

// 	tests := []struct {
// 		name  string
// 		input []*terraform.Options
// 	}{
// 		{
// 			name:  "basic-public-cluster",
// 			input: []*terraform.Options{network(t), publicAksCluster(t)},
// 		},
// 	}

// 	for _, test := range tests {

// 		t.Run(test.name, func(t *testing.T) {

// 			// Create provider.tf files in each module involved in this test
// 			networkProvider, err := NewProvider(test.input[0].TerraformDir + "/provider.tf")
// 			if err != nil {
// 				t.Fatal(err)
// 			}
// 			defer networkProvider.Delete()
// 			networkProvider.Create()

// 			aksProvider, err := NewProvider(test.input[1].TerraformDir + "/provider.tf")
// 			if err != nil {
// 				t.Fatal(err)
// 			}
// 			defer aksProvider.Delete()
// 			aksProvider.Create()

// 			var networkModuleOutput string
// 			var aksModuleInput map[string]interface{}

// 			// Deploy network resources
// 			defer terraform.Destroy(t, test.input[0])
// 			terraform.InitAndApply(t, test.input[0])

// 			// Fetch output from network module
// 			networkModuleOutput = terraform.OutputJson(t, test.input[0], "")
// 			err = json.Unmarshal([]byte(networkModuleOutput), &aksModuleInput)
// 			if err != nil {
// 				t.Fatal("error - could not unmarshal output from dependencies deployment")
// 			}

// 			// Parse network module output
// 			vnetId := aksModuleInput["vnet_id"].(map[string]interface{})["value"].(string)
// 			natGwId := aksModuleInput["nat_gateway_id"].(map[string]interface{})["value"].(string)

// 			// Replace mock values with the values parsed from the network module
// 			test.input[1].Vars["virtual_network_id"] = vnetId
// 			test.input[1].Vars["user_managed_nat_gateway_resource_id"] = natGwId

// 			// Deploy AKS to network
// 			defer terraform.Destroy(t, test.input[1])
// 			terraform.Init(t, test.input[1])
// 			terraform.ApplyAndIdempotent(t, test.input[1])

// 		})
// 	}
// }
