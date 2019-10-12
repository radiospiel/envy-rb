package envy

import (
	"crypto/aes"
	"crypto/cipher"
)

func newAesCipher() cipher.Block {
	aesCipher, err := aes.NewCipher(readSecret())
	if err != nil {
		panic("aes.NewCipher")
	}

	return aesCipher
}

func encryptBlocks(src []byte) []byte {
	aesCipher := newAesCipher()
	iv := make([]byte, aes.BlockSize) // We use an IV of all 0.
	encrypter := cipher.NewCBCEncrypter(aesCipher, iv)

	dest := make([]byte, len(src))
	encrypter.CryptBlocks(dest, src)
	return dest
}

func decryptBlocks(src []byte) []byte {
	if len(src)%aes.BlockSize != 0 {
		panic("decryptBlocks: src is not a multiple of the block size")
	}

	aesCipher := newAesCipher()
	iv := make([]byte, aes.BlockSize) // We use an IV of all 0.
	decrypter := cipher.NewCBCDecrypter(aesCipher, iv)

	dest := make([]byte, len(src))
	decrypter.CryptBlocks(dest, src)
	return dest
}
