package main

import (
    "fmt"
    "os"
    "encoding/json"
    "time"
    "strconv"
    "encoding/hex"
    "github.com/pschlump/AesCCM"
	"crypto/aes"
)

const TagLength = 16
const NonceLength = 12

func check(e error) {
    if e != nil {
        fmt.Println(e.Error())
        panic(e)
    }
}

func main() {
    register, err := os.ReadFile("../../shared/register.json")
    check(err)
    
    var registration map[string]interface{}
    err = json.Unmarshal([]byte(register), &registration)
    check(err)

    date := registration["date"].(map[string]interface{})
    /*
    fmt.Printf("Date   : %02d-%02d-%04d\n", 
        (uint)(date["day"].(float64)), 
        (uint)(date["month"].(float64)),
        (uint)(date["year"].(float64)))

    fmt.Printf("OTP    : %06d\n", (uint)(registration["otp"].(float64)))
    fmt.Printf("TransID: %s\n", registration["transid"].(string))
    */

    // Read test data from file
    testData, err := os.ReadFile("../../shared/testdata.json")
    check(err)
    
    // Parse JSON test data
    var res map[string]interface{}
    err = json.Unmarshal([]byte(testData), &res)
    check(err)
    
    body := res["body"].(map[string]interface{})
    
    /*
    fmt.Printf("iv           = %s\n", body["iv"].(string));
    fmt.Printf("enc_userid   = %s\n", body["enc_userid"].(string));
    fmt.Printf("tag_userid   = %s\n", body["tag_userid"].(string));
    fmt.Printf("userid       = %s\n", body["userid"].(string));
    fmt.Printf("enc_password = %s\n", body["enc_password"].(string));
    fmt.Printf("tag_password = %s\n", body["tag_password"].(string));
    */
    
    // Build the decryption key
    /*
    now := time.Now().Local()
    today := now
    */
    month := time.Month((int)(date["month"].(float64)))
    today := time.Date(
        (int)(date["year"].(float64)), 
        month,
        (int)(date["day"].(float64)), 
        0, 0, 0, 0, time.Local)
    
    dateStr, err := strconv.Atoi(fmt.Sprintf("%d%02d", today.Day(), today.Month()))
    check(err)
    dateHex := fmt.Sprintf("%03x", dateStr)
    
    otp := (int) (registration["otp"].(float64))
    otpHex := fmt.Sprintf("%05x", otp)
    transId := registration["transid"].(string)
    keyHex := fmt.Sprintf("%s%s%s", dateHex, transId, otpHex)
    
    key, err := hex.DecodeString(keyHex)
	check(err)
    
    // Prepare to decrypt user ID and password
    aes, err := aes.NewCipher(key[:])
    check(err)
    
    cipher, err := aesccm.NewCCM(aes, TagLength, NonceLength)
    check(err)
    
    nonce := []byte(body["iv"].(string))
    
    // Decrypt user ID
    encUserId := body["enc_userid"].(string)
    tagUserId := body["tag_userid"].(string)
    userIdTagHex := fmt.Sprintf("%s%s", encUserId, tagUserId)
    userIdTagBin, err := hex.DecodeString(userIdTagHex)
    check(err)
    
    userId, err := cipher.Open(nil, nonce, userIdTagBin, nil)
    check(err)
    
    fmt.Printf("User ID  = %s\n", userId)
    
    // Decrypt password
    encPassword := body["enc_password"].(string)
    tagPassword := body["tag_password"].(string)
    passwordTagHex := fmt.Sprintf("%s%s", encPassword, tagPassword)
    passwordTagBin, err := hex.DecodeString(passwordTagHex)
    check(err)
    
    password, err := cipher.Open(nil, nonce, passwordTagBin, nil)
    check(err)
    
    fmt.Printf("Password = %s\n", password)
    
}
