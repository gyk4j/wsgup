use std::fs;
use std::error::Error;
use std::str;
use json;

use chrono::{NaiveDate}; // DateTime, Local, 

use aes::Aes128;
use ccm::{
    aead::{Aead, KeyInit, generic_array::GenericArray}, // OsRng,   
    consts::{U16, U12},
    Ccm,
};


// AES-128-CCM type with tag and nonce size equal to 16 and 12 bytes respectively
pub type Aes128Ccm = Ccm<Aes128, U16, U12>;

fn main() -> Result<(), Box<dyn Error>> {
    let register: String = fs::read_to_string("../../shared/register.json")?;
    let registration = json::parse(register.as_str()).unwrap();

    /*
    println!("Date   : {}-{}-{}", 
        registration["date"]["day"].as_u32().unwrap(), 
        registration["date"]["month"].as_u23().unwrap(), 
        registration["date"]["year"].as_i32().unwrap());
    println!("OTP    : {}", 
        registration["otp"].as_u32().unwrap());
    println!("TransID: {}", 
        registration["transid"].as_str().unwrap());
    */

    // Read test data from file
    let testdata: String = fs::read_to_string("../../shared/testdata.json")?;
    //println!("{}", message);
    
    // Parse JSON test data
    let res = json::parse(testdata.as_str()).unwrap();
    
    /*
    println!("iv           = {}", res["body"]["iv"].as_str().unwrap());
    println!("enc_userid   = {}", res["body"]["enc_userid"]);
    println!("tag_userid   = {}", res["body"]["tag_userid"]);
    println!("userid       = {}", res["body"]["userid"]);
    println!("enc_password = {}", res["body"]["enc_password"]);
    println!("tag_password = {}", res["body"]["tag_password"]);
    */
    
    // Build the decryption key
    
    /*
    let now: DateTime<Local> = Local::now();
    let today: NaiveDate = now.date_naive();
    */
    let today: NaiveDate = NaiveDate::from_ymd_opt(
        registration["date"]["year"].as_i32().unwrap(), 
        registration["date"]["month"].as_u32().unwrap(), 
        registration["date"]["day"].as_u32().unwrap()
    ).unwrap();

    let date_hex = format!("{:03x}", today.format("%d%m").to_string().parse::<i32>().unwrap());
    
    let otp = registration["otp"].as_u32().unwrap();
    let otp_hex = format!("{:05x}", otp);
    let transid = registration["transid"].as_str().unwrap();
    let key_hex = format!("{date_hex}{transid}{otp_hex}");

    let key = hex::decode(key_hex).unwrap();
    
    // Prepare to decrypt user ID and password
    let cipher = Aes128Ccm::new_from_slice(&key).unwrap();
    let nonce_str: String = res["body"]["iv"].as_str().unwrap().to_string();
    let nonce: &GenericArray<u8, U12> = GenericArray::from_slice(nonce_str.as_bytes());
    
    // Decrypt user ID
    let enc_userid = res["body"]["enc_userid"].as_str().unwrap().to_string();
    let tag_userid = res["body"]["tag_userid"].as_str().unwrap().to_string();
    let userid_tag_hex = format!("{enc_userid}{tag_userid}");
    let userid_tag_bin = hex::decode(userid_tag_hex).unwrap();
    let userid = cipher.decrypt(nonce, &userid_tag_bin[..]).unwrap();
    println!("User ID  = {}", str::from_utf8(&userid).unwrap());
    
    // Decrypt password
    let enc_password = res["body"]["enc_password"].as_str().unwrap().to_string();
    let tag_password = res["body"]["tag_password"].as_str().unwrap().to_string();
    let password_tag_hex = format!("{enc_password}{tag_password}");
    let password_tag_bin = hex::decode(password_tag_hex).unwrap();
    let password = cipher.decrypt(nonce, &password_tag_bin[..]).unwrap();
    println!("Password = {}", str::from_utf8(&password).unwrap());
    
    /*
    let key = Aes128Ccm::generate_key(&mut OsRng);
    let cipher = Aes128Ccm::new(&key);    
    let nonce: &GenericArray<u8, U12> = GenericArray::from_slice(b"unique nonce");
    let plaintext = b"plaintext message";
    let ciphertext = cipher.encrypt(nonce, &plaintext[..]).unwrap();
    let decrypted = cipher.decrypt(nonce, &ciphertext[..]).unwrap();
    assert_eq!(&decrypted, b"plaintext message");
    
    println!("Decrypted = {}", str::from_utf8(&decrypted).unwrap());
    */
    
    Ok(())
}

