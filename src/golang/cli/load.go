package cli

import "github.com/spf13/cobra"

// go get github.com/Wing924/shellwords

import (
	"encoding/json"
	"fmt"
	"github.com/Wing924/shellwords"
)

func init() {
	var opts_json bool
	var opts_export bool

	var cmd = &cobra.Command{
		Use:   "load",
		Short: "Load an envy file",
		Long:  `Load an envy file`,
		Args:  cobra.ExactArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			path := args[0]

			config := mustLoadConfig(path)

			if opts_json {
				jsonData, err := json.MarshalIndent(config, "", " ")
				check(err)

				fmt.Printf("%s\n", jsonData)
			} else {
				prefix := ""
				if opts_export {
					prefix = "export "
				}

				for k, v := range config {
					fmt.Printf("%s%s=%s\n", prefix, k, shellwords.Escape(v))
				}
			}
		},
	}

	cmd.Flags().BoolVarP(&opts_json, "json", "j", false, "Print as JSON")
	cmd.Flags().BoolVarP(&opts_export, "export", "e", false, "Print as sh(1) export")

	rootCmd.AddCommand(cmd)
}
