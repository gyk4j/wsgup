#ifndef AESCCM_H
#define AESCCM_H

void handleErrors(void);

int ccm_decrypt(
    unsigned char *ciphertext, 
    int ciphertext_len,
    unsigned char *aad, int aad_len,
    unsigned char *tag,
    unsigned char *key,
    unsigned char *iv,
    unsigned char *plaintext
);

#endif