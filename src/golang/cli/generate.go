package cli

import "github.com/spf13/cobra"

func init() {
	var cmd = &cobra.Command{
		Use:   "generate",
		Short: "Generate an envy file",
		Long:  `Generate and edit an envy file`,
		Args:  cobra.ExactArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			// edit(args[0])
		},
	}

	rootCmd.AddCommand(cmd)
}
