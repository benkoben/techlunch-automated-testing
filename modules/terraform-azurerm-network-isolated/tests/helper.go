package tests

import (
	"fmt"
	"os"
	"os/exec"

	tfjson "github.com/hashicorp/terraform-json"
)

const (
	dependencyTemplates = "dependencies/"
)

func locateTerraformExec() string {
	tfPath, err := exec.LookPath("terraform")
	if err != nil {
		fmt.Printf("lookup terraform binary: %s\n", err)
		os.Exit(1)
	}
	return tfPath
}

func parseResourceAddresses(plan *tfjson.Plan) []string {
	var addreses []string
	for _, resource := range plan.ResourceChanges {
		addreses = append(addreses, resource.Address)
	}
	return addreses
}
