package cli

import (
	"fmt"
)

type SecretShowOptions struct {
}

func (opts *SecretShowOptions) Execute(args []string) error {
	fmt.Printf("load %#v\n", args)
	return nil
}

func init() {
	var options SecretShowOptions

	parser.AddCommand("secret:show",
		"secret:show command",
		"The command....",
		&options)
}
