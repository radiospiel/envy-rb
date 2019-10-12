package envy

import (
	"bufio"
	"io"
	"log"
	"os"
	"regexp"
)

type Mode int

const (
	Mode_Line Mode = iota
	Mode_Value
	Mode_Secured_Value
)

// reads a file line by line, yielding each line into the \a yield callback function.
func eachLine(file io.Reader, yield func(string) error) error {
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := scanner.Text()
		err := yield(line)
		if err != nil {
			log.Fatal(err)
			return err
		}
	}

	return scanner.Err()
}

// returns all matches for rex inside s. Useful to get submatches.
func rex_match(s string, rex *regexp.Regexp) []string {
	matches := rex.FindAllStringSubmatch(s, -1)

	if matches == nil || len(matches) == 0 {
		return nil
	}

	return matches[0]
}

/*
 * builds regexps for parsing in ParseFile
 */
var rex_comment *regexp.Regexp
var rex_blank_line *regexp.Regexp
var rex_start_of_secure_block *regexp.Regexp
var rex_start_of_block *regexp.Regexp
var rex_key_value *regexp.Regexp

func init() {
	rex_comment = regexp.MustCompile(`^\s*#`)
	rex_blank_line = regexp.MustCompile(`^\s*$`)
	rex_start_of_secure_block = regexp.MustCompile(`^\s*\[((.+)\.)?secure\]$`)
	rex_start_of_block = regexp.MustCompile(`^\s*\[(.+)\]$`)
	rex_key_value = regexp.MustCompile(`^\s*([a-zA-Z0-9_]+)\s*=\s*(.*)\s*$`)
}

/*
 * Opens envy file, and iterates over it line by line.
 *
 * This function yields (mode, pt1, pt2) which can have the following values:
 *
 *    Mode_Line, line, _
 *    Mode_Secured_Value key, value
 *    Mode_Value key, value
 *
 */
func ParseFile(path string, yield func(mode Mode, pt1 string, pt2 string)) error {
	const null = ""

	secure_block := false

	file, _ := os.Open(path)
	defer file.Close()

	return eachLine(file, func(line string) error {
		var m []string

		if m = rex_match(line, rex_comment); m != nil {
			yield(Mode_Line, line, null)
		} else if m = rex_match(line, rex_blank_line); m != nil {
			yield(Mode_Line, line, null)
		} else if m = rex_match(line, rex_start_of_secure_block); m != nil {
			secure_block = true
			yield(Mode_Line, line, null)
		} else if m = rex_match(line, rex_start_of_block); m != nil {
			secure_block = false
			yield(Mode_Line, line, null)
		} else if m = rex_match(line, rex_key_value); m != nil {
			if secure_block {
				yield(Mode_Secured_Value, m[1], m[2])
			} else {
				yield(Mode_Value, m[1], m[2])
			}
		} else {
			yield(Mode_Line, line, null)
		}

		return nil
	})
}
