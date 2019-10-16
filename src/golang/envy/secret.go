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
		_secretFile = determineSecretFile()
	}

	return _secretFile
}

const ENVY_BASE_NAME = ".secret.envy"

func determineSecretFile() string {
	path, ok := os.LookupEnv("ENVY_SECRET_PATH")
	if ok {
		log.Printf("DBG load secret from %s (as per ENVY_SECRET_PATH)", path)
		return path
	}

	/*
	 * when running as root read setcret from /etc/secret.envy
	 */

	if os.Geteuid() == 0 {
		path = "/etc/" + ENVY_BASE_NAME
	} else {
		path = os.Getenv("HOME") + "/" + ENVY_BASE_NAME
	}

	log.Printf("DBG load secret from %s", path)

	return path
}

var _binary_secret []byte

/*
 * read secret from file
 */
func readSecret() []byte {

	if _binary_secret != nil {
		return _binary_secret
	}

	secret, err := ioutil.ReadFile(secretFile())

	if err != nil {
		log.Fatal(err)
	}

	_binary_secret, err = hex.DecodeString(string(secret))
	if err != nil {
		log.Fatal(err)
	}

	return _binary_secret
}

func SecretMustExist() {
	readSecret()
}
