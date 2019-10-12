package cli

import (
	"fmt"
)

type SecretRestoreOptions struct {
	Force bool `long:"force" description:"force"`
}

func (opts *SecretRestoreOptions) Execute(args []string) error {
	fmt.Printf("load %#v\n", args)
	return nil
}

func init() {
	var options SecretRestoreOptions

	parser.AddCommand("secret:restore",
		"secret:restore command",
		"The command....",
		&options)
}
