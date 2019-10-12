package cli

import (
//	"fmt"
)

type GenerateOptions struct {
	// Force bool `short:"f" long:"force" description:"Force removal of files"`
}

func (opts *GenerateOptions) Execute(args []string) error {
	// fmt.Printf("Removing (force=%v): %#v\n", x.Force, args)
	return nil
}

func init() {
	var opts GenerateOptions

	parser.AddCommand("generate",
		"generate an envy file",
		"The generate command....",
		&opts)
}
