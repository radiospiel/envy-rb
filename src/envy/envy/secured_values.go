package envy

import (
	"crypto/aes"
	"encoding/base64"
	"log"
	"strings"
)

func isPrintable(ch byte) bool {
	return ch >= 32 && ch < 127
}

func trimNonprintable(buf []byte) []byte {
	i := 0
	for i < len(buf) && isPrintable(buf[i]) {
		i += 1
	}
	return buf[:i]
}

/*
 * If the str string starts with "envy:" we decode this string.
 */
func DecryptSecuredValue(str string) string {
	str = strings.TrimPrefix(str, "envy:")

	/*
	 * remove prefix, decode base64
	 */
	encrypted, err := base64.StdEncoding.DecodeString(str)
	if err != nil {
		log.Fatal(err)
	}

	decrypted := decryptBlocks(encrypted)
	decrypted = trimNonprintable(decrypted)
	return string(decrypted)
}

/*
 * takes a value string \a str, and encrypts and wraps it into a secured value.
 */
func EncryptSecuredValue(str string) string {
	/*
	 * convert string into binary data. Also pad to become a multiple of aes.BlockSize.
	 * We do this by adding "\0" bytes. (These will be removed in DecryptSecuredValue)
	 */
	decrypted_bin := []byte(str)
	padding := (aes.BlockSize - (len(decrypted_bin) % aes.BlockSize)) % aes.BlockSize
	decrypted_bin = append(decrypted_bin, make([]byte, padding)...)

	/*
	 * encrypt, base64-encode, and prefix
	 */
	encrypted_bin := encryptBlocks(decrypted_bin)
	encrypted := base64.StdEncoding.EncodeToString(encrypted_bin)
	return "envy:" + encrypted
}
