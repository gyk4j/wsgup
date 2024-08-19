#ifndef MAIN_H
#define MAIN_H

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif

#define NONCE_LENGTH 12
#define TAG_LENGTH 16

#define HEX_DATE_LEN 3
#define HEX_TRANSID_LEN 24
#define HEX_OTP_LEN 5
// Should be 32 hex characters = 16 bytes = 128 bits key
#define HEX_KEY_LEN (HEX_DATE_LEN + HEX_TRANSID_LEN + HEX_OTP_LEN)

int main(char* argc, char** argv);
unsigned char* read_file(const char* filename);

cJSON* get(cJSON *obj, const char* key);
char* get_str(cJSON *obj, const char* key);
int get_int(cJSON *obj, const char* key);
unsigned char* hex_decode(const char* hexstr);

#endif