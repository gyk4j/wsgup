#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'

require 'json'
require 'openssl'

TAG_LENGTH = 16
NONCE_LENGTH = 12

ALGORITHM = 'aes-128-ccm'

raise "Bad tag length" unless TAG_LENGTH === (128 / 8)

# Check support for required algorithm
ciphers = OpenSSL::Cipher.ciphers
if not ciphers.include?(ALGORITHM)
    abort("ERROR: Required cryptographic algorithm '" + ALGORITHM + "' is not supported by your current Ruby version/interpreter.")
end

register = File.read('../../shared/register.json')
registration = JSON.parse(register)

# Read test data from file
test_data = File.read('../../shared/testdata.json');

=begin
printf("Date   : %02d-%02d-%04d\n", 
    registration["date"]["day"], 
    registration["date"]["month"],
    registration["date"]["year"]);

printf("OTP    : %06d\n", registration["otp"]);
printf("TransID: %s\n", registration["transid"]);
=end

# Parse JSON test data
res = JSON.parse(test_data)

=begin
printf("iv           = %s\n", res["body"]["iv"]);
printf("enc_userid   = %s\n", res["body"]["enc_userid"]);
printf("tag_userid   = %s\n", res["body"]["tag_userid"]);
printf("userid       = %s\n", res["body"]["userid"]);
printf("enc_password = %s\n", res["body"]["enc_password"]);
printf("tag_password = %s\n", res["body"]["tag_password"]);
=end

# Build the decryption key
# today = Time.now
# today = Time.new

today = Time.local(
    registration["date"]["year"], 
    registration["date"]["month"], 
    registration["date"]["day"])
    
date_str = sprintf("%d%02d", today.day, today.month);
date_hex = sprintf("%03x", date_str.to_i);

otp_hex = sprintf("%05x", registration["otp"].to_i);

transid = registration["transid"];

key_hex = sprintf("%s%s%s", date_hex, transid, otp_hex);

key = [key_hex].pack('H*')

# Prepare to decrypt user ID and password
nonce = res["body"]["iv"];

# Decrypt user ID
cipher = OpenSSL::Cipher.new(ALGORITHM).decrypt
cipher.iv_len = NONCE_LENGTH
cipher.auth_tag_len = TAG_LENGTH
cipher.key = key

cipher.iv = nonce

enc_userid = res["body"]["enc_userid"]
enc_userid_bin = [enc_userid].pack('H*')
#cipher.ccm_data_len = enc_userid_bin.length

if cipher.authenticated?
    tag_userid = res["body"]["tag_userid"]
    tag_userid_bin = [tag_userid].pack('H*')
    cipher.auth_tag = tag_userid_bin
    #cipher.auth_data = ""
end

begin
    userid = cipher.update(enc_userid_bin) + cipher.final
rescue OpenSSL::Cipher::CipherError
    puts "ERROR: Decryption failed (wrong password, iv or tag?)."
else
    printf("User ID  = %s\n", userid)
end

# Decrypt password
cipher = OpenSSL::Cipher.new(ALGORITHM).decrypt
cipher.iv_len = NONCE_LENGTH
cipher.auth_tag_len = TAG_LENGTH
cipher.key = key

cipher.iv = nonce

enc_password = res["body"]["enc_password"]
enc_password_bin = [enc_password].pack('H*')
#cipher.ccm_data_len = enc_password_bin.length

if cipher.authenticated?
    tag_password = res["body"]["tag_password"]
    tag_password_bin = [tag_password].pack('H*')
    cipher.auth_tag = tag_password_bin
    #cipher.auth_data = ""
end

begin
    password = cipher.update(enc_password_bin) + cipher.final
rescue OpenSSL::Cipher::CipherError
    puts "ERROR: Decryption failed (wrong password, iv or tag?)."
else
    printf("Password = %s\n", password)
end



