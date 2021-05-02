package envy

import (
	"crypto/rand"
	"encoding/hex"
	"io/ioutil"
	"log"
	"os"
)

var _secretFile string

func SecretFile() string {
	if _secretFile == "" {
		_secretFile = determineSecretFile()
	}

	return _secretFile
}

const ENVY_BASE_NAME = ".secret.envy"

func determineSecretFile() string {
	path, ok := os.LookupEnv("ENVY_SECRET_PATH")
	if ok {
		log.Printf("DBG using secret files in %s (as per ENVY_SECRET_PATH)", path)
		return path
	}

	/*
	 * when running as root read secret from /etc/secret.envy
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

func GenerateSecret() {
	new_secret := make([]byte, 16) // We use an IV of all 0.

	n, err := rand.Read(new_secret)
	if err != nil {
		log.Fatal(err)
	}

	if n != 16 {
		log.Fatal("Cannot read enough random data")
	}

	writeSecret(new_secret)
}

func writeSecret(secret []byte) error {
	path := SecretFile()
	if _, err := os.Stat(path); err == nil {
		log.Fatalf("secret file exists already: %s", path)
	}

	hex_secret := hex.EncodeToString(secret)

	err := ioutil.WriteFile(path, []byte(hex_secret), 0400)

	if err == nil {
		log.Printf("generated secret file: %s", path)
	}

	return err
}

/*
 * read secret from file
 */
func readSecret() []byte {
	if _binary_secret != nil {
		return _binary_secret
	}

	secret, err := ioutil.ReadFile(SecretFile())

	if err != nil {
		log.Fatal(err)
	}

	if len(secret) != 32 {
		log.Fatal("secret must be 32 byte")
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
