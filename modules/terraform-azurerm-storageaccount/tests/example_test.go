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

// Testing scenarios are defined with functions such as this one.
// Usually TerraformDir, Reconfigure and Upgrade can be left as is. Reference docs can be found here: https://pkg.go.dev/github.com/gruntwork-io/terratest@v0.44.0/modules/terraform#Options
// Vars is the input that the module expects. These are equivalent for a tfvars file or using TF_VAR environment variables.
func mockModuleInput(t *testing.T) *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../.",
		Reconfigure:  true,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"location":             "northeurope",
			"resource_group_name":  "rg-test",
			"storage_account_name": "athensdemo20231004",
		},
	}
}

// --- Dry-runs
// The following function is designed to only perform dry-runs on isolated modules.
//
// The below example performs terraform init, validate & plan on each test in tests[].
// the plan is saved before all resources are parsed, which are then in turn compared with test.want.
// if the plan matches test.want then tests pass.
func TestDry_Example(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		input   *terraform.Options
		want    []string
		options struct {
			planOut string
		}
	}{
		{
			name:  "example-dry-run",
			input: mockModuleInput(t),
			// The order of the elements is important
			// Tip: Run a test to see the order of the resources
			want: []string{
				"azurerm_resource_group.module",
				"azurerm_storage_account.module",
			},
			options: struct{ planOut string }{
				planOut: "mockModule.tfplan",
			},
		},
	}

	for _, test := range tests {
		// Runs each test in the tests table as a subset of the unit test.
		// Each test is run as an individual goroutine.
		t.Run(test.name, func(t *testing.T) {
			provider, err := NewProvider(test.input.TerraformDir + "/provider.tf")
			if err != nil {
				t.Fatal(err)
			}
			defer provider.Delete()
			provider.Create()

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

// --- Unit tests
// Test_UT stands for unit test. Which tests modules isolated from each other.
// Some modules might not support unit tests because of infrastructure dependencies (deploying multiple modules), feel free to use the TestIT_Example function instead.
//
// The following example function runs isolated functionality tests on each test case in tests[]. Notice that the same mockModule function is used as test.input.
// For each iteration of tests, terraform init, apply x 2 (idempotency checking) and terraform destroy is run. The destroy is deffered to make sure that destroy always runs
// even if the apply failed.
func TestUT_Example(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name  string
		input *terraform.Options
	}{
		{
			name:  "simple-unittest-example",
			input: mockModuleInput(t),
		},
	}

	for _, test := range tests {
		provider, err := NewProvider(test.input.TerraformDir + "/provider.tf")
		if err != nil {
			t.Fatal(err)
		}
		defer provider.Delete()
		provider.Create()

		t.Run(test.name, func(t *testing.T) {
			defer terraform.Destroy(t, test.input)
			terraform.Init(t, test.input)
			terraform.ApplyAndIdempotent(t, test.input)
		})
	}
}
