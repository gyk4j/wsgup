const fs = require('fs')

try {
    // If there's no 'crypto' module support, we cannot decrypt the credentials.
    // So we just quit immediately.
    let crypto = require('crypto');

    let today = new Date()

    let registration = {
        "date": {
            "year": today.getYear() + 1900,
            "month": today.getMonth()+1,
            "day": today.getDate()
        },
        "otp": parseInt(String(Math.round(Math.random()*1000000)).padStart(6, '0')),
        "transid": "053786654500000000000000"
    }

    fs.writeFile("register.json", JSON.stringify(registration, null, 2), (error) => {
        if (error) {
            console.log('An error has occurred ', error)
            return
        }
        console.log('register.json written successfully')
    })

    // Build the encryption key
    let nonce = Buffer.from("Hello World!", "utf8") // 12 characters/bytes
    let dateHex = ((registration["date"]["day"] * 100) + registration["date"]["month"]).toString(16).padStart(3, '0')
    let otpHex = registration["otp"].toString(16).padStart(5, '0')
    let keyHex = `${dateHex}${registration.transid}${otpHex}`
    let key = Buffer.from(keyHex, 'hex')

    // Prepare to encrypt user ID and password
    function makeId(length) {
        let result = ''
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
        const charactersLength = characters.length
        for (counter = 0; counter < length; counter++) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength))
        }
        return result
    }

    function makeProvider() {
        const providers = [
            "singtel-wsg",
            "starhub",
            "m1net",
            "simba",
            "myrepublic"
        ]
        return providers[Math.floor(Math.random() * providers.length)]
    }

    const TAG_LENGTH = 16
    const NONCE_LENGTH = 12

    const ALGORITHM = 'aes-128-ccm'
    const OPTIONS = {
        authTagLength: TAG_LENGTH
    }
    
    // Encrypt userid
    let cipher = crypto.createCipheriv(ALGORITHM, key, nonce, OPTIONS)

    let userid = "essa-" + makeId(26) + "@" + makeProvider()
    
    let encUserId = cipher.update(Buffer.from(userid, "utf8"), null, 'hex')
    encUserId += cipher.final('hex')
    let tagUserId = cipher.getAuthTag().toString('hex')
    
    // Encrypt password
    cipher = crypto.createCipheriv(ALGORITHM, key, nonce, OPTIONS)
    
    let password = "this is a legible random plaintext test password"
    
    let encPassword = cipher.update(Buffer.from(password, "utf8"), null, 'hex')
    encPassword += cipher.final('hex')
    let tagPassword = cipher.getAuthTag().toString('hex')

    let res = {
        "api": "create_user_r12x1b",
        "body": {
            "enc_password": encPassword,
            "enc_userid": encUserId,
            "iv": nonce.toString('utf8'),
            "tag_password": tagPassword,
            "tag_userid": tagUserId,
            "userid": userid
        },
        "status": {
            "result": "ok",
            "resultcode": 1100
        },
        "version": "2.7"
    }

    fs.writeFile("testdata.json", JSON.stringify(res, null, 2), (error) => {
        if (error) {
            console.log('An error has occurred ', error)
            return
        }
        console.log('testdata.json written successfully')
    })
  
} catch (err) {
    console.error(err);
}

