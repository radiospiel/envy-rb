package cli

import (
	"fmt"
)

type SecretBackupOptions struct {
	Force bool `long:"force" description:"force"`
}

func (opts *SecretBackupOptions) Execute(args []string) error {
	fmt.Printf("load %#v\n", args)
	return nil
}

func init() {
	var options SecretBackupOptions

	parser.AddCommand("secret:backup",
		"secret:backup ",
		"The generate command....",
		&options)
}
