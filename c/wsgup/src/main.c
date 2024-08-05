#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <cJSON.h>
#include "aesccm.h"
#include "main.h"

int main(char* argc, char** argv){
    // register is a keyword in C. So we append a "_json" suffix.
    char* register_json = read_file("../../shared/register.json");
    if(register_json == NULL){
        return -1; //goto end;
    }
    
    //puts(register_json);
    cJSON *registration = cJSON_Parse(register_json);
    cJSON *date = get(registration, "date");
    /*
    printf("Date   : %02d-%02d-%04d\n", 
        get_int(date, "day"), 
        get_int(date, "month"), 
        get_int(date, "year"));
    printf("OTP    : %06d\n", 
        get_int(registration, "otp"));
    printf("TransID: %s\n", 
        get_str(registration, "transid"));
    */
    
    // Read test data from file
    char* test_data_json = read_file("../../shared/testdata.json");
    if(test_data_json == NULL){
        return -1; //goto end;
    }
    //puts(test_data_json);
    
    // Parse JSON test data
    cJSON *res = cJSON_Parse(test_data_json);
    cJSON *body = get(res, "body");
    /*
    printf("iv           = %s\n", get_str(body, "iv"));
    printf("enc_userid   = %s\n", get_str(body, "enc_userid"));
    printf("tag_userid   = %s\n", get_str(body, "tag_userid"));
    printf("userid       = %s\n", get_str(body, "userid"));
    printf("enc_password = %s\n", get_str(body, "enc_password"));
    printf("tag_password = %s\n", get_str(body, "tag_password"));
    */
    
    // Build the decryption key
    time_t now;
    struct tm* today = NULL;
    /*
    now = time(NULL);   
    */
    struct tm tm_date;
    tm_date.tm_year = get_int(date, "year")-1900;  // The number of years since 1900
    tm_date.tm_mon = get_int(date, "month")-1;     // month, range 0 to 11
    tm_date.tm_mday = get_int(date, "day");        // day of the month, range 1 to 31
    tm_date.tm_hour = 0;
    tm_date.tm_min = 0;
    tm_date.tm_sec = 0;
    tm_date.tm_isdst = 0;    
    
    now = mktime(&tm_date);    
    //printf(ctime(&now));

    today = localtime(&now);    
    
    char date_hex[HEX_DATE_LEN + 1];    // Add extra for null-terminated string
    date_hex[HEX_DATE_LEN] = 0;         // Ensure string termination
    char date_dec[5];                   // %e%m format = e.g. 3112 (4 digits) + 1 null terminating char
    date_dec[4] = 0;                    // Ensure string termination
    //sprintf(date_dec, "%d%02d", today->tm_mday, today->tm_mon+1);
    size_t bytes = strftime(date_dec, 5, "%e%m", today);
    if(bytes == 0){
        fprintf(stderr, "date_dec buffer too small.\n");
        return -1; //goto end;
    }
    // atoi skips leading spaces (if day is less than 10)
    sprintf(date_hex, "%x", atoi(date_dec));
    
    assert(strlen(date_hex) == HEX_DATE_LEN);
    
    int otp = get_int(registration, "otp");
    char otp_hex[HEX_OTP_LEN + 1];      // Add extra for null-terminated string
    otp_hex[HEX_OTP_LEN] = 0;           // Ensure string termination
    sprintf(otp_hex, "%x", otp);
    
    assert(strlen(otp_hex) == HEX_OTP_LEN);
    
    char transid[HEX_TRANSID_LEN + 1];
    strncpy(transid, get_str(registration, "transid"), HEX_TRANSID_LEN + 1);
    
    assert(strlen(transid) == HEX_TRANSID_LEN);
    
    char key_hex[HEX_KEY_LEN + 1];      // Add extra for null-terminated string
    key_hex[HEX_KEY_LEN] = 0;           // Ensure string termination
    
    memset(key_hex, 0, HEX_KEY_LEN);
    strncpy(key_hex, date_hex, HEX_KEY_LEN);
    strncat(key_hex, transid, HEX_KEY_LEN);
    strncat(key_hex, otp_hex, HEX_KEY_LEN);
    assert(strlen(key_hex) == HEX_KEY_LEN);
    
    unsigned char* key = NULL;
    key = hex_decode(key_hex);
    
    // Prepare to decrypt user ID and password
    char* nonce_str = get_str(body, "iv");
    assert(strlen(nonce_str) == NONCE_LENGTH);
    
    // Decrypt user ID
    char* enc_userid = get_str(body, "enc_userid");
    unsigned char* enc_userid_bin = hex_decode(enc_userid);
    
    char* tag_userid = get_str(body, "tag_userid");
    unsigned char* tag_userid_bin = hex_decode(tag_userid);
    assert((strlen(tag_userid) / 2) == TAG_LENGTH);
    
    size_t userid_len = strlen(enc_userid) / 2;
    unsigned char userid[userid_len + 1];
    memset(userid, 0, userid_len + 1);
    
    int userid_length = ccm_decrypt(
        enc_userid_bin,         // unsigned char *ciphertext,
        strlen(enc_userid) / 2, // int ciphertext_len,
        NULL,                   // unsigned char *aad, 
        0,                      // int aad_len,
        tag_userid_bin,         // unsigned char *tag,
        key,                    // unsigned char *key,
        nonce_str,              // unsigned char *iv,
        userid);                // unsigned char *plaintext)
    
    if(userid_length > 0){
        printf("User ID : %s\n", userid);
    }
    else{
        puts("ERROR: Decryption failed (wrong password, iv or tag?).");
    }
    
    // Decrypt password
    char* enc_password = get_str(body, "enc_password");
    unsigned char* enc_password_bin = hex_decode(enc_password);
    
    char* tag_password = get_str(body, "tag_password");
    unsigned char* tag_password_bin = hex_decode(tag_password);
    assert((strlen(tag_password) / 2) == TAG_LENGTH);
    
    size_t password_len = strlen(enc_password) / 2;
    unsigned char password[password_len + 1];
    memset(password, 0, password_len + 1);
    
    int password_length = ccm_decrypt(
        enc_password_bin,           // unsigned char *ciphertext,
        strlen(enc_password) / 2,   // int ciphertext_len,
        NULL,                       // unsigned char *aad, 
        0,                          // int aad_len,
        tag_password_bin,           // unsigned char *tag,
        key,                        // unsigned char *key,
        nonce_str,                  // unsigned char *iv,
        password);                  // unsigned char *plaintext)
    
    if(password_length > 0){
        printf("Password: %s\n", password);
    }
    else{
        puts("ERROR: Decryption failed (wrong password, iv or tag?).");
    }
    
    int status = (userid_length == 0 || password_length == 0);
    
end:
    if(key != NULL)
        free(key);                  // malloc by hex_decode
    if(today != NULL)
        free(today);                // malloc by localtime
    if(res != NULL)
        cJSON_Delete(res);          // malloc by cJSON_Parse
    if(registration != NULL)
        cJSON_Delete(registration); // malloc by cJSON_Parse
    if(test_data_json != NULL)
        free(test_data_json);       // malloc by read_file
    if(register_json != NULL)
        free(register_json);        // malloc by read_file
    
    return status;
}

unsigned char* read_file(const char* filename){
    unsigned char* string = NULL;
    FILE *f = fopen(filename, "rb");
    if(f != NULL){
        fseek(f, 0, SEEK_END);
        long fsize = ftell(f);
        fseek(f, 0, SEEK_SET);  /* same as rewind(f); */

        string = malloc(fsize + 1);
        fread(string, fsize, 1, f);
        fclose(f);

        string[fsize] = 0;
    }
    return string;
}

cJSON* get(cJSON *obj, const char* key){
    if (obj == NULL)
    {
        const char *error_ptr = cJSON_GetErrorPtr();
        if (error_ptr != NULL)
        {
            fprintf(stderr, "Error before: %s\n", error_ptr);
        }
    }
    
    cJSON *found = cJSON_GetObjectItemCaseSensitive(obj, key);
    return found;
}

char* get_str(cJSON *obj, const char* key){
    char* value = NULL;
    const cJSON* found = get(obj, key);
    if (found != NULL && cJSON_IsString(found) && (found->valuestring != NULL))
    {
        value = found->valuestring;
    }
    return value;
}

int get_int(cJSON *obj, const char* key){
    int value = -1;
    const cJSON* found = get(obj, key);
    if (found != NULL && cJSON_IsNumber(found))
    {
        value = found->valueint;
    }
    return value;
}


// https://gist.github.com/xsleonard/7341172
unsigned char* hex_decode(const char* hexstr)
{
    size_t len = strlen(hexstr);
    assert(len % 2 == 0);
    
    size_t final_len = len / 2;
    unsigned char* chrs = (unsigned char*)malloc((final_len+1) * sizeof(*chrs));
    for (size_t i=0, j=0; j<final_len; i+=2, j++)
        chrs[j] = (hexstr[i] % 32 + 9) % 25 * 16 + (hexstr[i+1] % 32 + 9) % 25;
    chrs[final_len] = '\0';
    return chrs;
}