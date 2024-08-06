package com.github.gyk4j.wsgup;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import java.security.Security;
import java.security.Key;
import java.security.InvalidKeyException;
import java.security.InvalidAlgorithmParameterException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.BadPaddingException;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.util.encoders.Hex;

public class App {
  
    public static final String BOUNCY_CASTLE = "BC";
    
    public static final String ALGORITHM = "AES";
    public static final String MODE = "CCM";
    public static final String PADDING = "NoPadding";
  
    public static final int TAG_LENGTH = 16;
    public static final int NONCE_LENGTH = 12;
    
    public static final Charset ENCODING_UTF8 = StandardCharsets.UTF_8;

    public static void main(String[] args) {
        try {
            File register = new File("../../../shared/register.json");
            ObjectMapper mapper = new ObjectMapper();
            JsonNode registration = mapper.readTree(register);

            JsonNode date = registration.get("date");
            /*
            System.out.format("Date   : %02d-%02d-%04d%n", 
                date.get("day").asInt(), 
                date.get("month").asInt(),
                date.get("year").asInt());

            System.out.format("OTP    : %06d%n", registration.get("otp").asInt());
            System.out.format("TransID: %s%n", registration.get("transid").asText());
            */

            // Read test data from file
            File testData = new File("../../../shared/testdata.json");

            // Parse JSON test data
            JsonNode res = mapper.readTree(testData);

            JsonNode body = res.get("body");

            /*
            System.out.format("iv           = %s%n", body.get("iv").asText());
            System.out.format("enc_userid   = %s%n", body.get("enc_userid").asText());
            System.out.format("tag_userid   = %s%n", body.get("tag_userid").asText());
            System.out.format("userid       = %s%n", body.get("userid").asText());
            System.out.format("enc_password = %s%n", body.get("enc_password").asText());
            System.out.format("tag_password = %s%n", body.get("tag_password").asText());
            */

            // Build the decryption key
            /*
            LocalDate today = LocalDate.now();
            */

            LocalDate today = LocalDate.of(
                date.get("year").asInt(),
                date.get("month").asInt(),
                date.get("day").asInt());

            DateTimeFormatter pattern = DateTimeFormatter.ofPattern("dMM");
            String dateStr = today.format(pattern);
            String dateHex = String.format("%03x", Integer.parseInt(dateStr));

            int otp = registration.get("otp").asInt();
            String otpHex = String.format("%05x", otp);
            String transId = registration.get("transid").asText();
            String keyHex = dateHex + transId + otpHex;

            byte[] key = Hex.decode(keyHex);

            // Prepare to decrypt user ID and password
            Security.addProvider(new BouncyCastleProvider());
            Key secretKey = new SecretKeySpec(key, ALGORITHM);

            byte[] nonce = body.get("iv").asText().getBytes(ENCODING_UTF8);
            GCMParameterSpec iv = new GCMParameterSpec(TAG_LENGTH*8, nonce);

            Cipher cipher = Cipher.getInstance(
                ALGORITHM + "/" + MODE + "/" + PADDING, 
                BOUNCY_CASTLE);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, iv);

            // Decrypt user ID
            String encUserId = body.get("enc_userid").asText();
            String tagUserId = body.get("tag_userid").asText();
            String userIdTagHex = encUserId + tagUserId;
            byte[] userIdTagBin = Hex.decode(userIdTagHex);

            String userId = new String(
                cipher.doFinal(userIdTagBin), 
                ENCODING_UTF8);

            System.out.format("User ID  = %s%n", userId);
            
            // Decrypt password
            String encPassword = body.get("enc_password").asText();
            String tagPassword = body.get("tag_password").asText();
            String passwordTagHex = encPassword + tagPassword;
            byte[] passwordTagBin = Hex.decode(passwordTagHex);

            String password = new String(
                cipher.doFinal(passwordTagBin), 
                ENCODING_UTF8);

            System.out.format("Password = %s%n", password);

        } catch(FileNotFoundException ex) {
            ex.printStackTrace();
        } catch(IOException ex) {
            ex.printStackTrace();
        } catch(NoSuchAlgorithmException ex) {
            ex.printStackTrace();
        } catch(NoSuchProviderException ex) {
            ex.printStackTrace();
        } catch(InvalidKeyException ex) {
            ex.printStackTrace();
        } catch(IllegalBlockSizeException ex) {
            ex.printStackTrace();
        } catch(NoSuchPaddingException ex) {
            ex.printStackTrace();
        } catch(InvalidAlgorithmParameterException ex) {
            ex.printStackTrace();
        } catch(BadPaddingException ex) {
            ex.printStackTrace();
        }
    }
}
