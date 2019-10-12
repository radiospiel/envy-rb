package cli

import (
	"../envy"
	"github.com/spf13/cobra"
	"log"
)

var (
	rootCmd = &cobra.Command{
		Use:   "envy",
		Short: "envy handles secure encvironments",
		Long:  `envy handles secure encvironments`,
	}
)

// Execute executes the root command.
func Execute() error {
	return rootCmd.Execute()
}

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func mustLoadConfig(path string) map[string]string {
	config, err := envy.LoadConfig(path)
	check(err)

	return config
}
