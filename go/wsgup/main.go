package main

import (
  "fmt"
  "os"
  "encoding/json"
)

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
    
    fmt.Printf("Date   : %02d-%02d-%04d\n", 
        (uint)(date["day"].(float64)), 
        (uint)(date["month"].(float64)),
        (uint)(date["year"].(float64)))

    fmt.Printf("OTP    : %06d\n", (uint)(registration["otp"].(float64)))
    fmt.Printf("TransID: %s\n", registration["transid"].(string))

    // Read test data from file
    testData, err := os.ReadFile("../../shared/testdata.json")
    check(err)
    
    // Parse JSON test data
    var res map[string]interface{}
    err = json.Unmarshal([]byte(testData), &res)
    check(err)
    
    body := res["body"].(map[string]interface{})
    
    fmt.Printf("iv           = %s\n", body["iv"].(string));
    fmt.Printf("enc_userid   = %s\n", body["enc_userid"].(string));
    fmt.Printf("tag_userid   = %s\n", body["tag_userid"].(string));
    fmt.Printf("userid       = %s\n", body["userid"].(string));
    fmt.Printf("enc_password = %s\n", body["enc_password"].(string));
    fmt.Printf("tag_password = %s\n", body["tag_password"].(string));
}
