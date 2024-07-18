use std::fs;
use std::error::Error;
use json;

fn main() -> Result<(), Box<dyn Error>> {
    // Read test data from file
    let message: String = fs::read_to_string("../../shared/testdata.json")?;
    //println!("{}", message);
    
    // Parse JSON test data
    let res = json::parse(message.as_str()).unwrap();
    
    println!("iv           = {}", res["body"]["iv"]);
    println!("enc_userid   = {}", res["body"]["enc_userid"]);
    println!("tag_userid   = {}", res["body"]["tag_userid"]);
    println!("userid       = {}", res["body"]["userid"]);
    println!("enc_password = {}", res["body"]["enc_password"]);
    println!("tag_password = {}", res["body"]["tag_password"]);
    
    Ok(())
}
