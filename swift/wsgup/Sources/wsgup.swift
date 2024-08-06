import Foundation
import CryptoSwift

let tagLength = 16
let nonceLength = 12

@main
struct Wsgup {
    static func main() {
        do {
            let register = try String(contentsOfFile: "../../shared/register.json")
                .data(using: .utf8)!
            let registration = try JSONSerialization.jsonObject(with: register) as! [String: Any]
            
            let date = registration["date"] as! [String: Any]
            /*
            print(String(format: "Date   : %02d-%02d-%04d", 
                date["day"] as! Int, 
                date["month"] as! Int,
                date["year"] as! Int))

            print(String(format: "OTP    : %06d", registration["otp"] as! Int))
            print(String(format: "TransID: %@", registration["transid"] as! String))
            */
            
            // Read test data from file
            let testData = try String(contentsOfFile: "../../shared/testdata.json")
                .data(using: .utf8)!
            
            // Parse JSON test data
            let res = try JSONSerialization.jsonObject(with: testData) as! [String: Any]
            
            let body = res["body"] as! [String: Any]

            /*
            print(String(format: "iv           = %@", body["iv"] as! String))
            print(String(format: "enc_userid   = %@", body["enc_userid"] as! String))
            print(String(format: "tag_userid   = %@", body["tag_userid"] as! String))
            print(String(format: "userid       = %@", body["userid"] as! String))
            print(String(format: "enc_password = %@", body["enc_password"] as! String))
            print(String(format: "tag_password = %@", body["tag_password"] as! String))
            */
            
            // Build the decryption key
            /*
            let now = Date()
            let today = now
            */
            var dateComponents = DateComponents()
            dateComponents.year = date["year"] as? Int
            dateComponents.month = date["month"] as? Int
            dateComponents.day = date["day"] as? Int
            
            let calendar = Calendar.current
            let today = calendar.date(from: dateComponents)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dMM"
            let dateStr = Int(formatter.string(from: today!)) ?? 0
            let dateHex = String(format: "%03x", dateStr)
            
            let otp = registration["otp"] as! Int;
            let otpHex = String(format: "%05x", otp)
            let transId = registration["transid"] as! String
            let keyHex = "\(dateHex)\(transId)\(otpHex)"
            
            let key = Array<UInt8>(hex: "0x\(keyHex)")
            
            // Prepare to decrypt user ID and passwor
            let nonce = (body["iv"] as! String).bytes
            
            // Decrypt user ID
            let encUserId = body["enc_userid"] as! String
            let tagUserId = body["tag_userid"] as! String
            let userIdTagHex = "\(encUserId)\(tagUserId)"
            let userIdTagBin = Array<UInt8>(hex: "0x" + userIdTagHex)
            
            do {
                let ccm = CCM(iv: nonce, tagLength: tagLength, messageLength: userIdTagBin.count - tagLength)
                //, additionalAuthenticatedData: data
                let cipher = try AES(key: key, blockMode: ccm, padding: .noPadding)
                
                let userIdBin = try cipher.decrypt(userIdTagBin)
                let userId = String(bytes: userIdBin, encoding: .utf8)
                
                // Unwrap optional String or use coalescing (password ?? "default")
                if let userId = userId {
                    print("User ID  = \(userId)")
                }
            } catch {
                print("ERROR: Decryption failed (wrong password, iv or tag?).")
            }
            
            // Decrypt password
            let encPassword = body["enc_password"] as! String
            let tagPassword = body["tag_password"] as! String
            let passwordTagHex = "\(encPassword)\(tagPassword)"
            let passwordTagBin = Array<UInt8>(hex: "0x" + passwordTagHex)
            
            do {
                let ccm = CCM(iv: nonce, tagLength: tagLength, messageLength: passwordTagBin.count - tagLength)
                //, additionalAuthenticatedData: data
                let cipher = try AES(key: key, blockMode: ccm, padding: .noPadding)
                
                let passwordBin = try cipher.decrypt(passwordTagBin)
                let password = String(bytes: passwordBin, encoding: .utf8)
                
                // Unwrap optional String or use coalescing (password ?? "default")
                if let password = password {
                    print("Password = \(password)")
                }
            } catch {
                print("ERROR: Decryption failed (wrong password, iv or tag?).")
            }
        } catch {
            print(error)
        }
    }
}


