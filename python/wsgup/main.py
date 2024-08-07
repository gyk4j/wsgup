#!/usr/bin/python3

# Prerequisite
# Install pycryptodome: python3 -m pip install -r requirements.txt

import json
from datetime import date
import codecs
from Crypto.Cipher import AES

TAG_LENGTH = 16
NONCE_LENGTH = 12

ENCODING_HEX = 'hex';
ENCODING_UTF8 = 'utf8';

def main():
    with open("../../shared/register.json", 'r') as file:
        register = file.read()
        
    registration = json.loads(register)
    
    # print("Date   : %02d-%02d-%04d" % (
        # registration["date"]["day"], 
        # registration["date"]["month"],
        # registration["date"]["year"]))

    # print("OTP    : %06d" % (registration["otp"]))
    # print("TransID: %s" % (registration["transid"]))
        
    with open("../../shared/testdata.json") as file:
        test_data = file.read()
        
    res = json.loads(test_data)
    
    # print("iv           = %s" % (res["body"]["iv"]));
    # print("enc_userid   = %s" % (res["body"]["enc_userid"]));
    # print("tag_userid   = %s" % (res["body"]["tag_userid"]));
    # print("userid       = %s" % (res["body"]["userid"]));
    # print("enc_password = %s" % (res["body"]["enc_password"]));
    # print("tag_password = %s" % (res["body"]["tag_password"]));
    
    # Build the decryption key
    
    # now = datetime.now()
    # today = date.today()
    
    today = date(
        int(registration["date"]["year"]),
        int(registration["date"]["month"]), 
        int(registration["date"]["day"]))
    date_str = int(today.strftime("%e%m").strip())
    date_hex = b"%03x" % date_str
    
    otp = int(registration["otp"])
    otp_hex = b"%05x" % otp
    
    transid = bytes(registration["transid"], ENCODING_UTF8)
    
    key_hex = date_hex + transid + otp_hex

    key = codecs.decode(key_hex, ENCODING_HEX)

    # Prepare to decrypt user ID and password
    nonce = bytes(res["body"]["iv"], ENCODING_UTF8)
    assert len(nonce) == NONCE_LENGTH
    
    # Decrypt user ID    
    enc_userid = res["body"]["enc_userid"]
    enc_userid_bin = codecs.decode(bytes(enc_userid, ENCODING_UTF8), encoding=ENCODING_HEX)
    
    tag_userid = res["body"]["tag_userid"]
    tag_userid_bin = codecs.decode(bytes(tag_userid, ENCODING_UTF8), encoding=ENCODING_HEX)
    assert len(tag_userid_bin) == TAG_LENGTH
    
    aes = AES.new(key, AES.MODE_CCM, nonce)
    aes.update(tag_userid_bin)
    userid_bin = aes.decrypt(enc_userid_bin)
    userid = userid_bin.decode()
    
    print("User ID  = %s" % (userid));
    
    # Decrypt password    
    enc_password = res["body"]["enc_password"]
    enc_password_bin = codecs.decode(bytes(enc_password, ENCODING_UTF8), encoding=ENCODING_HEX)
    
    tag_password = res["body"]["tag_password"]
    tag_password_bin = codecs.decode(bytes(tag_password, ENCODING_UTF8), encoding=ENCODING_HEX)
    assert len(tag_password_bin) == TAG_LENGTH
    
    aes = AES.new(key, AES.MODE_CCM, nonce)
    aes.update(tag_password_bin)
    password_bin = aes.decrypt(enc_password_bin)
    password = password_bin.decode()
    
    print("Password = %s" % (password));
    
#enddef main()

if __name__=="__main__": 
    main() 