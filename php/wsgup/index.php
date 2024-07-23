<?php
const TAG_LENGTH = 16;
const NONCE_LENGTH = 12;

const ALGORITHM = 'aes-128-ccm';
const OPTIONS = OPENSSL_RAW_DATA;

const BASE_HEX = 16;
const BASE_DECIMAL = 10;

const ENCODING_HEX = 'hex';
const ENCODING_UTF8 = 'utf8';

const LOCALE = 'en-US';
const TIME_ZONE = 'Asia/Singapore';

assert(TAG_LENGTH === (128 / 8));
assert(openssl_cipher_iv_length(ALGORITHM) === NONCE_LENGTH);

// AEAD encryption and AES-CCM support were added in PHP 7.1.0.
//
// In PHP versions 7.2.x below 7.2.34, 7.3.x below 7.3.23 and 7.4.x below 
// 7.4.11, when AES-CCM mode is used with openssl_encrypt() function with 12 
// bytes IV, only first 7 bytes of the IV is actually used.
//
// This causes incorrect decryption failure even when correct password, IV and
// tag are provided.
//
// See: https://nvd.nist.gov/vuln/detail/CVE-2020-7069
if (
    version_compare(phpversion(), '7.2.34', '<') ||
    (strpos(phpversion(), "7.2.") === 0 && version_compare(phpversion(), '7.2.34', '<')) ||
    (strpos(phpversion(), "7.3.") === 0 && version_compare(phpversion(), '7.3.23', '<')) ||
    (strpos(phpversion(), "7.4.") === 0 && version_compare(phpversion(), '7.4.11', '<'))
    )
{
    exit("ERROR: " . __FILE__ . " requires PHP 7.2.34, 7.3.23 or 7.4.11  and above for OpenSSL AES-CCM support.\n");
}

// Check support for required algorithm
$ciphers = openssl_get_cipher_methods();
if (!in_array(ALGORITHM, $ciphers))
{
    exit("ERROR: Required cryptographic algorithm '" . ALGORITHM . "' is not supported by your current PHP version/interpreter.\n");
}

$register = file_get_contents('../../shared/register.json');
$registration = json_decode($register, true);

/*
printf("Date   : %02d-%02d-%04d", 
    $registration["date"]["day"], 
    $registration["date"]["month"],
    $registration["date"]["year"]) . "\n";

printf("OTP    : %06d", $registration["otp"]) . "\n";
printf("TransID: %s", $registration["transid"]) . "\n";
*/

// Read test data from file
$testData = file_get_contents('../../shared/testdata.json');
// Parse JSON test data
$res = json_decode($testData, true);

/*
printf("iv           = %s\n", $res["body"]["iv"]);
printf("enc_userid   = %s\n", $res["body"]["enc_userid"]);
printf("tag_userid   = %s\n", $res["body"]["tag_userid"]);
printf("userid       = %s\n", $res["body"]["userid"]);
printf("enc_password = %s\n", $res["body"]["enc_password"]);
printf("tag_password = %s\n", $res["body"]["tag_password"]);
*/

// Build the decryption key
/*
$today = getdate();
*/

date_default_timezone_set(TIME_ZONE);
$unixtime = mktime
    (
        0, 0, 0, 
        $registration["date"]["month"], 
        $registration["date"]["day"], 
        $registration["date"]["year"]
    );
$today = getdate($unixtime);

$dateStr = sprintf("%d%02d", $today["mday"], $today["mon"]);
$dateHex = sprintf("%03x", intval($dateStr));

$otpHex = sprintf("%05x", intval($registration["otp"]));

$transId = $registration["transid"];

$keyHex = sprintf("%s%s%s", $dateHex, $transId, $otpHex);

$key = hex2bin($keyHex);

// Prepare to decrypt user ID and password
$nonce = $res["body"]["iv"];

// Decrypt user ID
$encUserId = $res["body"]["enc_userid"];
$encUserIdBin = hex2bin($encUserId);

$tagUserId = $res["body"]["tag_userid"];
$tagUserIdBin = hex2bin($tagUserId);

$userId = openssl_decrypt
    (
        $encUserIdBin,
        ALGORITHM,
        $key,
        OPENSSL_RAW_DATA,
        $nonce,
        $tagUserIdBin,
        ""
    );

if ($userId !== false)
{
    printf("User ID  = %s\n", $userId);
}
else
{
    exit("ERROR: Decryption failed (wrong password, iv or tag?).\n");
}

// Decrypt password
$encPassword = $res["body"]["enc_password"];
$encPasswordBin = hex2bin($encPassword);

$tagPassword = $res["body"]["tag_password"];
$tagPasswordBin = hex2bin($tagPassword);

$password = openssl_decrypt
    (
        $encPasswordBin,
        ALGORITHM,
        $key,
        OPENSSL_RAW_DATA,
        $nonce,
        $tagPasswordBin,
        ""
    );

if ($password !== false)
{
    printf("Password = %s\n", $password);
}
else
{
    exit("ERROR: Decryption failed (wrong password, iv or tag?).\n");
}

?>