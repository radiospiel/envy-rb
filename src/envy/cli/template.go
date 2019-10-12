package cli

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"strings"
)

type TemplateOptions struct {
}

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

func (opts *TemplateOptions) Execute(args []string) error {
	path := extractArgAtOffset(args, 0)

	config := mustLoadConfig(path)

	template, err := ioutil.ReadFile(extractArgAtOffset(args, 1))

	if err != nil {
		panic(err)
	}

	_ = config
	r := regexp.MustCompile(`{{[^}]+}}`)
	result := r.ReplaceAllStringFunc(string(template), func(m string) string {
		parts := strings.SplitN(m[2:len(m)-2], ":", 2)
		return mustLookupConfigValue(config, parts)
	})

	fmt.Printf("%s", result)
	return nil
}

func init() {
	var options TemplateOptions

	parser.AddCommand("template",
		"fill in settings into a template file",
		"The template command fills in values in a template file from the values",
		&options)
}
