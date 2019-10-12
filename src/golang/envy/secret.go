package envy

import (
	"encoding/hex"
	"io/ioutil"
	"log"
	"os"
)

var _secretFile string

func secretFile() string {
	if _secretFile == "" {
		panic("_secretFile must be set")
	}

	return _secretFile
}

func setSecretFile(secretFile string) {
	_secretFile = secretFile
}

/*
 * read secret from file
 */
func readSecret() []byte {
	secret, err := ioutil.ReadFile(secretFile())

	if err != nil {
		log.Fatal(err)
	}

	binary_secret, err := hex.DecodeString(string(secret))
	if err != nil {
		log.Fatal(err)
	}

	return binary_secret
}

const ENVY_BASE_NAME = ".secret.envy"

func init() {
	path, ok := os.LookupEnv("ENVY_SECRET_PATH")
	if ok {
		log.Printf("DBG load secret from %s (as per ENVY_SECRET_PATH)", path)
	} else {
		path = os.Getenv("HOME") + "/" + ENVY_BASE_NAME
		log.Printf("DBG load secret from %s", path)
	}

	setSecretFile(path)
}
