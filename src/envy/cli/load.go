package cli

// go get github.com/Wing924/shellwords

import (
	"encoding/json"
	"fmt"
	"github.com/Wing924/shellwords"
)

type LoadOptions struct {
	Json   bool `long:"json" description:"Print as JSON"`
	Export bool `long:"export" description:"Print as sh(1) exports"`
}

func (opts *LoadOptions) Execute(args []string) error {
	path := extractArg(args)

	config := mustLoadConfig(path)

	if opts.Json {
		jsonData, err := json.MarshalIndent(config, "", " ")
		if err != nil {
			return err
		}

		fmt.Printf("%s\n", jsonData)
	} else {
		prefix := ""
		if opts.Export {
			prefix = "export "
		}

		for k, v := range config {
			fmt.Printf("%s%s=%s\n", prefix, k, shellwords.Escape(v))
		}
	}

	return nil
}

func init() {
	var opts LoadOptions

	parser.AddCommand("load",
		"load an envy file",
		"The generate command....",
		&opts)
}
