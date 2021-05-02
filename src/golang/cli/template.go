package cli

import "github.com/spf13/cobra"

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"strings"
)

func mustLookupConfigValue(config map[string]string, key_and_default []string) string {
	log.Printf("key_and_default %q", key_and_default)
	key := key_and_default[0]
	value, ok := config[key]
	if !ok {
		value, ok = os.LookupEnv(key)
	}

	if !ok && len(key_and_default) >= 2 {
		value = key_and_default[1]
		ok = true
	}

	if !ok {
		log.Fatalf("Cannot find value for setting %s", key)
	}

	return value
}

func do_template(path string, template_path string) {
	config := mustLoadConfig(path)

	template, err := ioutil.ReadFile(template_path)
	check(err)

	_ = config
	r := regexp.MustCompile(`{{[^}]+}}`)
	result := r.ReplaceAllStringFunc(string(template), func(m string) string {
		parts := strings.SplitN(m[2:len(m)-2], ":", 2)
		return mustLookupConfigValue(config, parts)
	})

	fmt.Printf("%s", result)
}

func init() {
	var cmd = &cobra.Command{
		Use:   "template",
		Short: "Fill in a template",
		Long:  `The template command fills in values in a template file from the values`,
		Args:  cobra.ExactArgs(2),
		Run: func(cmd *cobra.Command, args []string) {
			path := args[0]
			template := args[1]
			do_template(path, template)
		},
	}

	rootCmd.AddCommand(cmd)
}
