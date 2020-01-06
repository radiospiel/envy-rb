package cli

import "github.com/spf13/cobra"

import ()

/*
 * Copy the current secret via ${SSH_BINARY:-ssh} to a target account.
 */
func do_secret_install(target_account string) {
}

func init() {
	var cmd = &cobra.Command{
		Use:   "secret:install",
		Short: "Install the current envy secret to a remote location",
		Long:  `Install the current envy secret to a remote location`,
		Args:  cobra.ExactArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			do_secret_install(args[0])
		},
	}

	rootCmd.AddCommand(cmd)
}
