package cli

import "github.com/spf13/cobra"

import ()

func init() {
	var cmd = &cobra.Command{
		Use:   "secret:restore",
		Short: "Restore the envy secret",
		Long:  `Restore the envy secret`,
		Args:  cobra.ExactArgs(0),
		Run: func(cmd *cobra.Command, args []string) {
		},
	}

	rootCmd.AddCommand(cmd)
}
