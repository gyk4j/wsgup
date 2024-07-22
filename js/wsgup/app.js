const TAG_LENGTH = 16
const NONCE_LENGTH = 12

const ALGORITHM = 'aes-128-ccm'
const OPTIONS = {
    authTagLength: TAG_LENGTH
}

const BASE_HEX = 16
const BASE_DECIMAL = 10

const ENCODING_HEX = 'hex'
const ENCODING_UTF8 = 'utf8'

const LOCALE = 'en-US'

let crypto;

try {
    // If there's no 'crypto' module support, we cannot decrypt the credentials.
    // So we just quit immediately.
    crypto = require('crypto');
    
    const registration = require('../../shared/register.json');
    
    const ddFormat = new Intl.NumberFormat(LOCALE, { 
        minimumIntegerDigits: 2, 
        minimumFractionDigits: 0 
    });
    
    const mmFormat = new Intl.NumberFormat(LOCALE, { 
        minimumIntegerDigits: 2, 
        minimumFractionDigits: 0 
    });
    
    const yyyyFormat = new Intl.NumberFormat(LOCALE, { 
        minimumIntegerDigits: 4, 
        minimumFractionDigits: 0,
        useGrouping: false // suppress commas in 1,000s
    });
    
    /*
    console.log("Date   : %s-%s-%s", 
        ddFormat.format(parseInt(registration["date"]["day"])), 
        mmFormat.format(parseInt(registration["date"]["month"])),
        yyyyFormat.format(parseInt(registration["date"]["year"])))

    console.log("OTP    : %d", parseInt(registration["otp"]))
    console.log("TransID: %s", registration["transid"])
    */
    
    const res = require('../../shared/testdata.json');
    
    /*
    console.log("iv           = %s", res["body"]["iv"]);
    console.log("enc_userid   = %s", res["body"]["enc_userid"]);
    console.log("tag_userid   = %s", res["body"]["tag_userid"]);
    console.log("userid       = %s", res["body"]["userid"]);
    console.log("enc_password = %s", res["body"]["enc_password"]);
    console.log("tag_password = %s", res["body"]["tag_password"]);
    */
    
    // Build the decryption key
    let today
    /*
    today = new Date()
    */
    today = new Date(
        parseInt(registration["date"]["year"]),
        parseInt(registration["date"]["month"])-1,
        parseInt(registration["date"]["day"]))
    
    const dateStr = new String(today.getDate()).concat(mmFormat.format(today.getMonth()+1))
    const dateHex = "000".concat(parseInt(dateStr, BASE_DECIMAL).toString(BASE_HEX)).substr(-3)
    
    const otpHex = "00000".concat(parseInt(registration["otp"], BASE_DECIMAL).toString(BASE_HEX)).substr(-5)    
    const transId = registration["transid"]
    const keyHex = `${dateHex}${transId}${otpHex}`
    
    const key = Buffer.from(keyHex, ENCODING_HEX)

    // Prepare to decrypt user ID and password
    // NOTE: Decipher instance *cannot be reused* in Node.js, so we'll have to
    //       recreate a new one each time.
    let cipher
    
    const nonce = Buffer.from(res["body"]["iv"], ENCODING_UTF8)

    // Decrypt user ID
    let encUserId = res["body"]["enc_userid"]
    let tagUserId = res["body"]["tag_userid"]
    let tagUserIdBin = Buffer.from(tagUserId, ENCODING_HEX)
    cipher = crypto.createDecipheriv(ALGORITHM, key, nonce, OPTIONS)
    cipher.setAuthTag(tagUserIdBin)
    let userIdBin = Buffer.from(encUserId, ENCODING_HEX)
    let userId = cipher.update(userIdBin, null, ENCODING_UTF8)
    userId += cipher.final(ENCODING_UTF8)

    console.log(`User ID  = ${userId}`)
    
    // Decrypt password
    let encPassword = res["body"]["enc_password"]
    let tagPassword = res["body"]["tag_password"]
    let tagPasswordBin = Buffer.from(tagPassword, ENCODING_HEX)
    cipher = crypto.createDecipheriv(ALGORITHM, key, nonce, OPTIONS)
    cipher.setAuthTag(tagPasswordBin)
    let passwordBin = Buffer.from(encPassword, ENCODING_HEX)
    let password = cipher.update(passwordBin, null, ENCODING_UTF8)
    password += cipher.final(ENCODING_UTF8)

    console.log(`Password = ${password}`)
  
} catch (err) {
    console.error(err);
}

