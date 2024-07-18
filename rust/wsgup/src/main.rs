use std::fs;
use std::error::Error;
use json;

//use base64::prelude::*;

/*
use aes::Aes128;
use ccm::{
    aead::{KeyInit, OsRng, generic_array::GenericArray}, //Unused: Aead, 
    consts::{U10, U13},
    Ccm,
};

// AES-128-CCM type with tag and nonce size equal to 10 and 13 bytes respectively
pub type Aes128Ccm = Ccm<Aes128, U10, U13>;
*/

fn main() -> Result<(), Box<dyn Error>> {
    // Read test data from file
    let message: String = fs::read_to_string("../../shared/testdata.json")?;
    //println!("{}", message);
    
    // Parse JSON test data
    let res = json::parse(message.as_str()).unwrap();
    
    println!("iv           = {}", res["body"]["iv"].as_str().unwrap());
    println!("enc_userid   = {}", res["body"]["enc_userid"]);
    println!("tag_userid   = {}", res["body"]["tag_userid"]);
    println!("userid       = {}", res["body"]["userid"]);
    println!("enc_password = {}", res["body"]["enc_password"]);
    println!("tag_password = {}", res["body"]["tag_password"]);
    
    /*
    let iv = BASE64_STANDARD.decode(res["body"]["iv"].as_str().unwrap()).unwrap_or_default();
    println!("==> iv           = {:?}", iv);
    */

    // Untested example not compiling. 
    // error[E0283]: type annotations needed for `&GenericArray<u8, N>`
    // Source: https://docs.rs/ccm/latest/ccm/
    
    /*
    let key = Aes128Ccm::generate_key(&mut OsRng);
    let cipher = Aes128Ccm::new(&key);    
    let nonce = GenericArray::from_slice(b"unique nonce."); // 13-bytes; unique per message
    let ciphertext = cipher.encrypt(nonce, b"plaintext message".as_ref())?;
    let plaintext = cipher.decrypt(nonce, ciphertext.as_ref())?;
    assert_eq!(&plaintext, b"plaintext message");
    */
    
    Ok(())
}
