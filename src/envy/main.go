package main

import (
	"./cli"
	"./envy"
	"fmt"
)

//import "log"

func printEnvyFile(path string) error {
	return envy.ParseFile(path, func(mode envy.Mode, pt1 string, pt2 string) {
		switch mode {
		case envy.Mode_Value:
			fmt.Printf("%s=%s\n", pt1, pt2)
		case envy.Mode_Secured_Value:
			value := envy.DecryptSecuredValue(pt2)
			fmt.Printf("%s=%s\n", pt1, value)
		case envy.Mode_Line:
			fmt.Printf("%s\n", pt1)
		}
	})
}

func trackEnvyFile(path string) error {
	return envy.ParseFile(path, func(mode envy.Mode, pt1 string, pt2 string) {
		switch mode {
		case envy.Mode_Value:
			value := pt2
			secured_value := envy.EncryptSecuredValue(value)
			unsecured_value := envy.DecryptSecuredValue(secured_value)
			fmt.Printf("unsecured %q\n", []string{pt1, pt2, value, secured_value, unsecured_value})
		case envy.Mode_Secured_Value:
			value := envy.DecryptSecuredValue(pt2)
			secured_value := envy.EncryptSecuredValue(value)
			unsecured_value := envy.DecryptSecuredValue(secured_value)
			fmt.Printf("secured   %q\n", []string{pt1, pt2, value, secured_value, unsecured_value})
			// case envy.Mode_Line:
			//   fmt.Printf("%s\n", pt1)
		}
	})
}

func loadEnvyFile(path string) error {
	config := make(map[string]string)

	err := envy.ParseFile(path, func(mode envy.Mode, pt1 string, pt2 string) {
		switch mode {
		case envy.Mode_Value:
			config[pt1] = pt2
		case envy.Mode_Secured_Value:
			config[pt1] = string(envy.DecryptSecuredValue(pt2))
		}
	})

	if err != nil {
		return err
	}

	fmt.Printf("env: %q\n", config)
	return nil
}

func main() {
	cli.Run()
	// const src = "spec/fixtures/config"
	//
	// trackEnvyFile(src)
	// // if err := printEnvyFile(in_file); err != nil {
	// //   log.Fatal(err)
	// // }
	// //
	// // if err := loadEnvyFile(in_file); err != nil {
	// //   log.Fatal(err)
	// // }
}
