using System;
using System.IO;
using System.Text.Json;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace wsgup
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                string register = File.ReadAllText(Path.Combine("..", "..", "shared", "register.json"));
                
                JsonDocument registration = JsonDocument.Parse(register);
                JsonElement date = registration.RootElement.GetProperty("date");
                
                /*
                Console.WriteLine(String.Format("Date   : {0}-{1}-{2}",
                    date.GetProperty("day").GetInt32().ToString("D2"),
                    date.GetProperty("month").GetInt32().ToString("D2"),
                    date.GetProperty("year").GetInt32().ToString("D4")));
                Console.WriteLine(String.Format("OTP    : {0}",
                    registration.RootElement.GetProperty("otp").GetInt32().ToString("D6")));
                Console.WriteLine(String.Format("TransID: {0}",
                    registration.RootElement.GetProperty("transid").GetString()));
                */
                
                string testData = File.ReadAllText(Path.Combine("..", "..", "shared", "testdata.json"));
                
                JsonDocument res = JsonDocument.Parse(testData);
                JsonElement body = res.RootElement.GetProperty("body");
                
                /*
                Console.WriteLine(String.Format("iv           = {0}", body.GetProperty("iv").GetString()));
                Console.WriteLine(String.Format("enc_userid   = {0}", body.GetProperty("enc_userid").GetString()));
                Console.WriteLine(String.Format("tag_userid   = {0}", body.GetProperty("tag_userid").GetString()));
                Console.WriteLine(String.Format("userid       = {0}", body.GetProperty("userid").GetString()));
                Console.WriteLine(String.Format("enc_password = {0}", body.GetProperty("enc_password").GetString()));
                Console.WriteLine(String.Format("tag_password = {0}", body.GetProperty("tag_password").GetString()));
                */
                
                // Build the decryption key
                /*
                DateTime now = DateTime.Now;
                DateTime today = DateTime.Today;
                */
                
                DateTime today = new DateTime
                (
                    date.GetProperty("year").GetInt32(),
                    date.GetProperty("month").GetInt32(),
                    date.GetProperty("day").GetInt32()
                );

                String dateHex = int.Parse(today.ToString("dMM")).ToString("x3");
                
                int otp = registration.RootElement.GetProperty("otp").GetInt32();
                string otpHex = otp.ToString("x5");
                string transid = registration.RootElement.GetProperty("transid").GetString();
                string keyHex = $"{dateHex}{transid}{otpHex}";
                
                byte[] key = HexDecode(keyHex);
                
                // Prepare to decrypt user ID and password
                using(AesCcm cipher = new AesCcm(key))
                {
                    string nonceStr = body.GetProperty("iv").GetString();
                    byte[] nonce = Encoding.UTF8.GetBytes(nonceStr);                

                    // Decrypt user ID
                    string encUserId = body.GetProperty("enc_userid").GetString();
                    byte[] encUserIdBin = HexDecode(encUserId);
                    string tagUserId = body.GetProperty("tag_userid").GetString();
                    byte[] tagUserIdBin = HexDecode(tagUserId);
                    byte[] userIdBin = new byte[encUserIdBin.Length];                    
                    cipher.Decrypt
                    (
                        nonce,
                        encUserIdBin,
                        tagUserIdBin,
                        userIdBin
                    );
                    string userId = Encoding.UTF8.GetString(userIdBin, 0, userIdBin.Length);
                    Console.WriteLine("User ID  = {0}", userId);
                    
                    // Decrypt password
                    string encPassword = body.GetProperty("enc_password").GetString();
                    byte[] encPasswordBin = HexDecode(encPassword);
                    string tagPassword = body.GetProperty("tag_password").GetString();
                    byte[] tagPasswordBin = HexDecode(tagPassword);
                    byte[] passwordBin = new byte[encPasswordBin.Length];                    
                    cipher.Decrypt
                    (
                        nonce,
                        encPasswordBin,
                        tagPasswordBin,
                        passwordBin
                    );
                    string password = Encoding.UTF8.GetString(passwordBin, 0, passwordBin.Length);
                    Console.WriteLine("Password = {0}", password);
                }
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }        
        }
        
        static byte[] HexDecode(string s)
        {
            byte[] bytes = new byte[s.Length / 2];
            
            for(int i = 0; i < bytes.Length; i++)
            {
                string b = s.Substring(i*2, 2);
                bytes[i] = byte.Parse(b, NumberStyles.HexNumber);
            }
            
            return bytes;
        }            
    }
}
