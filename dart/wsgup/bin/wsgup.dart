import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/ccm.dart';

const pointyCastle = "PC";
    
const algorithm = "AES";
const mode = "CCM";
const padding = "NoPadding";

const tagLength = 16;
const nonceLength = 12;

const encodingHex = 16;

void main(List<String> arguments) async {  
  try {
    final register = await File("../../shared/register.json").readAsString();
    final registration = json.decode(register);
    
    final date = registration["date"];
    
    /*
    final dd = date["day"].toString().padLeft(2, '0');
    final mm = date["month"].toString().padLeft(2, '0');
    final yyyy = date["year"].toString().padLeft(4, '0');
    print("Date   : $dd-$mm-$yyyy");

    print("OTP    : ${registration['otp']}");
    print("TransID: ${registration['transid']}");
    */
    
    // Read test data from file
    final testData = await File("../../shared/testdata.json").readAsString();
    
    // Parse JSON test data
    final res = json.decode(testData);
    
    final body = res["body"];
    
    /*
    print("iv           = ${body['iv']}");
    print("enc_userid   = ${body['enc_userid']}");
    print("tag_userid   = ${body['tag_userid']}");
    print("userid       = ${body['userid']}");
    print("enc_password = ${body['enc_password']}");
    print("tag_password = ${body['tag_password']}");
    */
    
    // Build the decryption key
    /*
    final today = DateTime.now();
    */
    
    final today = DateTime(
      date["year"], 
      date["month"],
      date["day"]
    );
    
    final dateStr = today.day.toString() + today.month.toString().padLeft(2, '0');
    final dateHex = int.parse(dateStr).toRadixString(encodingHex).padLeft(3, '0');
    
    int otp = registration["otp"];
    String otpHex = otp.toRadixString(encodingHex).padLeft(5, '0');
    String transId = registration["transid"];
    String keyHex = dateHex + transId + otpHex;
            
    final key = Uint8List.fromList(HEX.decode(keyHex));
    
    // Prepare to decrypt user ID and password
    final secretKey = KeyParameter(key);
    
    final nonce = utf8.encode(body["iv"]);
    final aad = Uint8List(0);
    final params = AEADParameters(secretKey, tagLength*8, nonce, aad);
    
    final engine = AESEngine();
    final cipher = CCMBlockCipher(engine)
      ..init(false, params); // false=decrypt
    
    // Decrypt user ID
    final encUserId = body["enc_userid"];
    final tagUserId = body["tag_userid"];
    final userIdTagHex = encUserId + tagUserId;
    final userIdTagBin = Uint8List.fromList(HEX.decode(userIdTagHex));
    
    // BUG: Always zero due to pointycastle-3.9.1/lib/block/modes/ccm.dart
    // processBlock => processBytes => returns 0;
    // If offset is never updated by processBlock in a loop decrypting  
    // block-by-block, heap memory allocation will eventually run out and crash.  
    // const offset = 0;
    // final userIdBin = Uint8List((encUserId.length / 2).toInt());
    // cipher.processBlock(userIdTagBin, offset, userIdBin, offset);
    // cipher.doFinal(userIdBin, offset);
    
    final userIdBin = cipher.process(userIdTagBin);
    final userId = utf8.decode(userIdBin);
    
    print("User ID  = $userId");
    
    // Decrypt password
    final encPassword = body["enc_password"];
    final tagPassword = body["tag_password"];
    final passwordTagHex = encPassword + tagPassword;
    final passwordTagBin = Uint8List.fromList(HEX.decode(passwordTagHex));
    
    // final passwordBin = Uint8List((encPassword.length / 2).toInt());
    // cipher.processBlock(passwordTagBin, offset, passwordBin, offset);
    // cipher.doFinal(passwordBin, offset);
    
    final passwordBin = cipher.process(passwordTagBin);
    final password = utf8.decode(passwordBin);
    
    print("Password = $password");
    
  } on PathNotFoundException catch(ex) {
    print('Exception details:\n $ex');
  } catch(ex, stackTrace) {
    print('Exception details:\n $ex');
    print('Stack trace:\n $stackTrace');
  }
}
