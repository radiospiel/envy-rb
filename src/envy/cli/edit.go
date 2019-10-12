package cli

import (
	"../envy"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
)

func copyEnvyFile(srcPath string, dest *os.File, do_encrypt bool) error {
	return envy.ParseFile(srcPath, func(mode envy.Mode, pt1 string, pt2 string) {
		switch mode {
		case envy.Mode_Value:
			log.Printf("> INSECURE %s=%s\n", pt1, pt2)

			fmt.Fprintf(dest, "%s=%s\n", pt1, pt2)
		case envy.Mode_Secured_Value:
			log.Printf("> SECURE   %s=%s\n", pt1, pt2)

			var value string
			if do_encrypt {
				value = envy.EncryptSecuredValue(pt2)
			} else {
				value = envy.DecryptSecuredValue(pt2)
			}

			fmt.Fprintf(dest, "%s=%s\n", pt1, value)

		case envy.Mode_Line:
			log.Printf("%s\n", pt1)
			fmt.Fprintf(dest, "%s\n", pt1)
		}
	})
}

func copyAndDecryptEnvyFile(srcPath string, dest *os.File) error {
	return copyEnvyFile(srcPath, dest, false)
}

func copyAndEncryptEnvyFile(srcPath string, dest *os.File) error {
	return copyEnvyFile(srcPath, dest, true)
}

type EditOptions struct {
}

func shell(str string) error {
	_, ok := os.LookupEnv("EDITOR")
	if !ok {
		os.Setenv("EDITOR", "vi")
	}

	cmd := exec.Command("bash", "-c", str) // editor, tmpFile.Name())
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

func (opts *EditOptions) Execute(args []string) error {
	path := extractArg(args)

	tmpFile, err := ioutil.TempFile("", "envy")
	// defer os.Remove(tmpFile.Name())

	if err != nil {
		log.Fatal(err)
	}

	if err = copyAndDecryptEnvyFile(path, tmpFile); err != nil {
		panic(err)
	}

	log.Printf("part 1\n")
	tmpFile.Close()

	/*
	 * run editor
	 */
	err = shell("$EDITOR " + tmpFile.Name())

	if err != nil {
		return err
	}

	log.Printf("part 2\n")

	log.Printf("editor was successful\n")

	log.Printf("part 3\n")

	dest, err := os.Create(path)
	if err != nil {
		log.Fatal(err)
	}
	defer dest.Close()

	log.Printf("part 4, tmpFile.Name: %s\n", tmpFile.Name())

	if err = copyAndEncryptEnvyFile(tmpFile.Name(), dest); err != nil {
		panic(err)
	}

	log.Printf("part 5\n")

	return nil
}

func init() {
	var options EditOptions

	parser.AddCommand("edit",
		"edit an envy file",
		"The edit command....",
		&options)
}
