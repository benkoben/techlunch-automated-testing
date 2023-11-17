package tests

// TODO: Write tests for helpers

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	tfjson "github.com/hashicorp/terraform-json"

	terratest "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/hashicorp/hcl/v2/gohcl"
	"github.com/hashicorp/hcl/v2/hclwrite"
	"github.com/zclconf/go-cty/cty"
)

const (
	DependencyTemplates = "dependencies/"
)

// Default test settings
const (
	DefaultTestPlanMode     = "normal"
	DefaultTestModuleSource = "./.."
	DefaultTestCommand      = "plan"
)

// ModuleTest wraps both terraform native testing options and terratest options
type ModuleTest struct {
	Path                 *os.File
	TerratestOpts        terratest.Options
	TerraformTestOptions TestOptions `hcl:"run,block"`
}

// Test is used to create test.hcl files during runtime
type TestOptions struct {
	TerraTestInitUpgrade     bool   // terraform init -upgrade=
	TerraTestInitReconfigure bool   // terraform init -reconfigure=
	TerraformTestName        string `hcl:"name,label"`
	TerraformTestCommand     string `hcl:"command,attr"`
	// TerraformTestPlanOptions    PlanOptions            `hcl:"plan_options,block"`
	// TerraformTestAssert         Assertion              `hcl:"assert,block"`
	// TerraformTestExpectFailures bool                   `hcl:"expect_failures,optional"`
	TestVariables map[string]cty.Value `hcl:"variables,block"`
	// TestModule                  Module                 `hcl:"module,optional"`
}

type PlanOptions struct {
	Mode    string   `hcl:"mode,label"`
	Refresh bool     `hcl:"refresh,attr"`
	Replace []string `hcl:"replace,attr"`
	Target  []string `hcl:"target,attr"`
}

type Module struct {
	Source string `hcl:"source,label"`
}

type Assertion struct {
	Condition    string `hcl:"condition,label"`
	ErrorMessage string `hcl:"error_message,label"`
}

// Create renders fields with hcl tags into a hcl.test file specified at mt.path
func (mt ModuleTest) Create() error {
	defer mt.Path.Close()

	f := hclwrite.NewEmptyFile()
	gohcl.EncodeIntoBody(&mt, f.Body())

	mt.Path.Write(f.Bytes())
	return nil
}

// Delete cleans up the tests by deleting mt.Path
func (mt ModuleTest) Delete() {
	_ = os.Remove(mt.Path.Name())
}

// NewModuleTest constructs a ModuleTest
func NewModuleTest(name string, o *TestOptions) (*ModuleTest, error) {
	// Set defaults
	if o.TerraformTestCommand == "" {
		o.TerraformTestCommand = DefaultTestPlanMode
	}

	// if o.TerraformTestPlanOptions.Mode == "" {
	// 	o.TerraformTestPlanOptions.Mode = DefaultTestPlanMode
	// }

	// if o.TestModule.Source == "" {
	// 	o.TestModule.Source = DefaultTestModuleSource
	// }

	// Define local variables
	testFilePath := filepath.Join("./..", fmt.Sprintf("%s.hcl.test", name))

	f, err := os.OpenFile(testFilePath, os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		return &ModuleTest{}, fmt.Errorf("could not open provided path: %s", err)
	}

	terraTestOptions := terratest.Options{
		// TerraformDir: o.TestModule.Source,
		Reconfigure: o.TerraTestInitReconfigure,
		Upgrade:     o.TerraTestInitUpgrade,
		// Vars:         o.TestVariables,
	}

	// Return constructed ModuleTest
	return &ModuleTest{
		TerratestOpts:        terraTestOptions,
		TerraformTestOptions: *o,
		Path:                 f,
	}, err
}

type Provider struct {
	path     *os.File
	Provider AzureRm `hcl:"provider,block"`
}

type AzureRm struct {
	Name     string   `hcl:"name,label"`
	Features Features `hcl:"features,block"`
}

type Features struct{}

func (p Provider) Create() error {
	defer p.path.Close()

	f := hclwrite.NewEmptyFile()
	gohcl.EncodeIntoBody(&p, f.Body())

	p.path.Write(f.Bytes())
	return nil
}

func (p Provider) Delete() {
	_ = os.Remove(p.path.Name())
}

func NewProvider(path string) (Provider, error) {

	f, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		return Provider{}, fmt.Errorf("could not open provided path: %s", err)
	}
	return Provider{
		path: f,
		Provider: AzureRm{
			Name:     "azurerm",
			Features: Features{},
		},
	}, nil
}

func LocateTerraformExec() string {
	tfPath, err := exec.LookPath("terraform")
	if err != nil {
		fmt.Printf("lookup terraform binary: %s\n", err)
		os.Exit(1)
	}
	return tfPath
}

func ParseResourceAddresses(plan *tfjson.Plan) []string {
	var addreses []string
	for _, resource := range plan.ResourceChanges {
		addreses = append(addreses, resource.Address)
	}
	return addreses
}
