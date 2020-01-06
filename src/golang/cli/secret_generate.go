package cli

import "github.com/spf13/cobra"

import ()

/*
 * Copy the current secret via ${SSH_BINARY:-ssh} to a target account.
 */
func do_secret_generate() {
}

func init() {
	var cmd = &cobra.Command{
		Use:   "secret:generate",
		Short: "Generate the envy secret",
		Long:  `Generate the envy secret`,
		Args:  cobra.ExactArgs(0),
		Run: func(cmd *cobra.Command, args []string) {
			do_secret_generate()
		},
	}

	rootCmd.AddCommand(cmd)
}
