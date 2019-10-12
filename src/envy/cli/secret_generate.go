package cli

import (
	"fmt"
)

type SecretGenerateOptions struct {
}

func (opts *SecretGenerateOptions) Execute(args []string) error {
	fmt.Printf("load %#v\n", args)
	return nil
}

func init() {
	var options SecretGenerateOptions

	parser.AddCommand("secret:generate",
		"secret:generate command ",
		"The command....",
		&options)
}
