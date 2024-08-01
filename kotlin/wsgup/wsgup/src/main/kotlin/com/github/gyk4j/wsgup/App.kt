package com.github.gyk4j.wsgup

import java.io.File
import java.io.FileNotFoundException
import java.io.IOException

import java.nio.charset.Charset
import java.nio.charset.StandardCharsets
import java.time.LocalDate
import java.time.format.DateTimeFormatter

import java.security.Security
import java.security.Key
import java.security.InvalidKeyException
import java.security.InvalidAlgorithmParameterException
import java.security.NoSuchAlgorithmException
import java.security.NoSuchProviderException
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.IvParameterSpec
import javax.crypto.IllegalBlockSizeException
import javax.crypto.NoSuchPaddingException
import javax.crypto.BadPaddingException

import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper

import org.bouncycastle.jce.provider.BouncyCastleProvider
import org.bouncycastle.util.encoders.Hex

// In many cases, the variable type and class can be omitted as it can be
// inferred during construction or initialization. This can reduce keystrokes
// and make the codes look shorter, more concise and cleaner.
//
// In case a value is returned by a method, the type can be ambiguous unless
// documentations are consulted or through the assistance of IDE that uses 
// reflection to determine and remember the data type. This is where explicit
// type declaration is useful.
//
// However, I have chosen to keep them solely for consistency with Java when
// doing cross-comparison. This is strictly a matter of personal preference.

const val BOUNCY_CASTLE : String = "BC"

const val ALGORITHM : String  = "AES"
const val MODE : String  = "CCM"
const val PADDING : String  = "NoPadding"

const val TAG_LENGTH : Int  = 16
const val NONCE_LENGTH : Int = 12

// NOTE: objects are not allowed for const values.
// Only primitive values like Int and String are allowed for const.
val ENCODING_UTF8 : Charset = StandardCharsets.UTF_8

fun main() {
    try {
        val register : File = File("../../../shared/register.json")
        val mapper : ObjectMapper = ObjectMapper()
        val registration : JsonNode = mapper.readTree(register)

        val date : JsonNode = registration.get("date")
        /*
        println("Date   : %02d-%02d-%04d".format( 
            date.get("day").asInt(), 
            date.get("month").asInt(),
            date.get("year").asInt()
        ))

        println("OTP    : %06d".format(registration.get("otp").asInt()))
        println("TransID: %s".format(registration.get("transid").asText()))
        */
        
        // Read test data from file
        val testData : File = File("../../../shared/testdata.json")

        // Parse JSON test data
        val res : JsonNode = mapper.readTree(testData)

        val body : JsonNode = res.get("body")
        
        /*
        println("iv           = %s".format(body.get("iv").asText()))
        println("enc_userid   = %s".format(body.get("enc_userid").asText()))
        println("tag_userid   = %s".format(body.get("tag_userid").asText()))
        println("userid       = %s".format(body.get("userid").asText()))
        println("enc_password = %s".format(body.get("enc_password").asText()))
        println("tag_password = %s".format(body.get("tag_password").asText()))
        */
        
        // Build the decryption key
        /*
        val today : LocalDate = LocalDate.now()
        */
        
        val today : LocalDate = LocalDate.of(
            date.get("year").asInt(),
            date.get("month").asInt(),
            date.get("day").asInt())
        
        val pattern : DateTimeFormatter = DateTimeFormatter.ofPattern("dMM")
        val dateStr : String = today.format(pattern)
        val dateHex : String = "%03x".format(Integer.parseInt(dateStr))

        val otp : Int = registration.get("otp").asInt()
        val otpHex : String = "%05x".format(otp)
        val transId : String = registration.get("transid").asText()
        val keyHex : String = dateHex + transId + otpHex

        val key : ByteArray = Hex.decode(keyHex)
        
        // Prepare to decrypt user ID and password
        Security.addProvider(BouncyCastleProvider())
        val secretKey : Key = SecretKeySpec(key, ALGORITHM)

        val nonce : ByteArray = body.get("iv").asText().toByteArray(ENCODING_UTF8)
        val iv : GCMParameterSpec = GCMParameterSpec(TAG_LENGTH*8, nonce)

        val cipher : Cipher = Cipher.getInstance(
            ALGORITHM + "/" + MODE + "/" + PADDING, 
            BOUNCY_CASTLE)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, iv)
        
         // Decrypt user ID
        val encUserId : String = body.get("enc_userid").asText()
        val tagUserId : String = body.get("tag_userid").asText()
        val userIdTagHex : String = encUserId + tagUserId
        val userIdTagBin : ByteArray = Hex.decode(userIdTagHex)

        val userId : String = String(
            cipher.doFinal(userIdTagBin), 
            ENCODING_UTF8)

        println("User ID  = %s".format(userId))
        
        // Decrypt password
        val encPassword : String = body.get("enc_password").asText()
        val tagPassword : String = body.get("tag_password").asText()
        val passwordTagHex : String = encPassword + tagPassword
        val passwordTagBin : ByteArray = Hex.decode(passwordTagHex)

        val password : String = String(
            cipher.doFinal(passwordTagBin), 
            ENCODING_UTF8)

        println("Password = %s".format(password))
        
    } catch(ex : FileNotFoundException) {
        ex.printStackTrace()
    } catch(ex : IOException) {
        ex.printStackTrace()
    } catch(ex : NoSuchAlgorithmException) {
        ex.printStackTrace()
    } catch(ex : NoSuchProviderException) {
        ex.printStackTrace()
    } catch(ex : InvalidKeyException) {
        ex.printStackTrace()
    } catch(ex : IllegalBlockSizeException) {
        ex.printStackTrace()
    } catch(ex : NoSuchPaddingException) {
        ex.printStackTrace()
    } catch(ex : InvalidAlgorithmParameterException) {
        ex.printStackTrace()
    } catch(ex : BadPaddingException) {
        ex.printStackTrace()
    }
}
