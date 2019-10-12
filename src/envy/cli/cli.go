package cli

import (
	"../envy"
	_ "errors"
	"fmt"
	"github.com/jessevdk/go-flags"
	"log"
	_ "strconv"
	_ "strings"
)

func extractArg(args []string) string {
	return extractArgAtOffset(args, 0)
}

func extractArgAtOffset(args []string, offset int) string {
	if len(args) <= offset {
		msg := fmt.Sprintf("args must have at least %d argument(s), but is %q", offset+1, args)
		panic(msg)
	}

	return args[offset]
}

func mustLoadConfig(path string) map[string]string {
	config, err := envy.LoadConfig(path)
	if err != nil {
		log.Fatal(err)
	}

	return config
}

type EditorOptions struct {
	Input  flags.Filename `short:"i" long:"input" description:"Input file" default:"-"`
	Output flags.Filename `short:"o" long:"output" description:"Output file" default:"-"`
}

// type Point struct {
//   X, Y int
// }
//
// func (p *Point) UnmarshalFlag(value string) error {
//   parts := strings.Split(value, ",")
//
//   if len(parts) != 2 {
//     return errors.New("expected two numbers separated by a ,")
//   }
//
//   x, err := strconv.ParseInt(parts[0], 10, 32)
//
//   if err != nil {
//     return err
//   }
//
//   y, err := strconv.ParseInt(parts[1], 10, 32)
//
//   if err != nil {
//     return err
//   }
//
//   p.X = int(x)
//   p.Y = int(y)
//
//   return nil
// }
//
// func (p Point) MarshalFlag() (string, error) {
//   return fmt.Sprintf("%d,%d", p.X, p.Y), nil
// }

/*
 * Define toplevel options
 */

type Options struct {
	// - application options

	// Example of verbosity with level
	Verbose []bool `short:"v" long:"verbose" description:"Verbose output"`

	// Example of optional value
	User string `short:"u" long:"user" description:"User name" optional:"yes"`

	// Example of map with multiple default values
	Users map[string]string `long:"users" description:"User e-mail map" default:"system:system@example.org" default:"admin:admin@example.org"`

	// Example of option group
	Editor EditorOptions `group:"Editor Options"`

	// Example of custom type Marshal/Unmarshal
	// Point Point `long:"point" description:"A x,y point" default:"1,2"`
}

var options Options

/*
 * create CLI parser.
 * This value is shared across the package so that other files in here can add
 * their own subcommands.
 */

var parser = flags.NewParser(&options, flags.Default)

func Run() error {
	_, err := parser.Parse()
	if err == nil {
		return nil
	}

	if flagsErr, ok := err.(*flags.Error); ok && flagsErr.Type == flags.ErrHelp {
		return nil
	}

	return err
}
