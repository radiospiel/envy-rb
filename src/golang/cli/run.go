package cli

import "github.com/spf13/cobra"

import (
	"os"
	"os/exec"
)

func run(path string, args []string) {
	/*
	 * fill in config into environment
	 */
	config := mustLoadConfig(path)

	for k, v := range config {
		os.Setenv(k, v)
	}

	/*
	 * create command and set arguments
	 */
	cmd := exec.Command(args[0], args[1:]...)

	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	err := cmd.Run()
	check(err)
}

func init() {
	var cmd = &cobra.Command{
		Use:   "run",
		Short: "Load an envy file and run command",
		Long:  `Load an envy file and run command`,
		Args:  cobra.MinimumNArgs(2),
		Run: func(cmd *cobra.Command, args []string) {
			path := args[0]
			run(path, args[1:])
		},
	}

	rootCmd.AddCommand(cmd)
}
