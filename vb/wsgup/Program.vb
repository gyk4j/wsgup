Option Explicit On
Option Infer Off
Option Strict On

Imports System
Imports System.IO
Imports System.Text.Json
Imports System.Globalization
Imports System.Security.Cryptography
Imports System.Text

Module Program
    Sub Main(args As String())
        Dim register As String = File.ReadAllText(Path.Combine("..", "..", "shared", "register.json"))
        
        Dim registration As JsonDocument = JsonDocument.Parse(register)     
        ' date is a keyword. So we append a suffix.
        Dim date_ As JsonElement = registration.RootElement.GetProperty("date")
        
        ' Console.WriteLine(String.Format("Date   : {0}-{1}-{2}",
            ' date_.GetProperty("day").GetInt32().ToString("D2"),
            ' date_.GetProperty("month").GetInt32().ToString("D2"),
            ' date_.GetProperty("year").GetInt32().ToString("D4")))
        ' Console.WriteLine(String.Format("OTP    : {0}",
            ' registration.RootElement.GetProperty("otp").GetInt32().ToString("D6")))
        ' Console.WriteLine(String.Format("TransID: {0}",
            ' registration.RootElement.GetProperty("transid").GetString()))
            
        Dim testData As String = File.ReadAllText(Path.Combine("..", "..", "shared", "testdata.json"))
                
        Dim res As JsonDocument = JsonDocument.Parse(testData)
        Dim body As JsonElement = res.RootElement.GetProperty("body")
        
        ' Console.WriteLine(String.Format("iv           = {0}", body.GetProperty("iv").GetString()))
        ' Console.WriteLine(String.Format("enc_userid   = {0}", body.GetProperty("enc_userid").GetString()))
        ' Console.WriteLine(String.Format("tag_userid   = {0}", body.GetProperty("tag_userid").GetString()))
        ' Console.WriteLine(String.Format("userid       = {0}", body.GetProperty("userid").GetString()))
        ' Console.WriteLine(String.Format("enc_password = {0}", body.GetProperty("enc_password").GetString()))
        ' Console.WriteLine(String.Format("tag_password = {0}", body.GetProperty("tag_password").GetString()))
        
        ' Build the decryption key
        
        ' Dim now As DateTime = DateTime.Now
        ' Dim today As DateTime = DateTime.Today
        
        Dim today As DateTime = New DateTime _
        ( _
            date_.GetProperty("year").GetInt32(), _
            date_.GetProperty("month").GetInt32(), _
            date_.GetProperty("day").GetInt32() _
        )
        
        Dim dateHex As String = Integer.Parse(today.ToString("dMM")).ToString("x3")
                
        Dim otp As Integer = registration.RootElement.GetProperty("otp").GetInt32()
        Dim otpHex As String = otp.ToString("x5")
        Dim transid As String = registration.RootElement.GetProperty("transid").GetString()
        Dim keyHex As String = $"{dateHex}{transid}{otpHex}"
        
        Dim key As Byte() = HexDecode(keyHex)
        
        ' Prepare to decrypt user ID and password
        Using cipher As AesCcm = New AesCcm(key)
            Dim nonceStr As String = body.GetProperty("iv").GetString()
            Dim nonce As Byte() = Encoding.UTF8.GetBytes(nonceStr)

            ' Decrypt user ID
            Dim encUserId As String = body.GetProperty("enc_userid").GetString()
            Dim encUserIdBin As Byte() = HexDecode(encUserId)
            Dim tagUserId As String = body.GetProperty("tag_userid").GetString()
            Dim tagUserIdBin As Byte() = HexDecode(tagUserId)
            
            ' NOTE: Need to subtract 1 as VB uses last index in array  
            ' declaration, rather than length. As array in VB, like C# are 
            ' zero-based, so the actual length/count becomes 1 extra.
            Dim userIdBin(encUserIdBin.Length - 1) As Byte
            
            cipher.Decrypt _
            ( _
                nonce, _
                encUserIdBin, _
                tagUserIdBin, _
                userIdBin _
            )
            Dim userId As String = Encoding.UTF8.GetString(userIdBin, 0, userIdBin.Length)
            Console.WriteLine("User ID  = {0}", userId)
            
            ' Decrypt password
            Dim encPassword As String = body.GetProperty("enc_password").GetString()
            Dim encPasswordBin As Byte() = HexDecode(encPassword)
            Dim tagPassword As String = body.GetProperty("tag_password").GetString()
            Dim tagPasswordBin As Byte() = HexDecode(tagPassword)
            
            ' NOTE: Need to subtract 1 as VB uses last index in array  
            ' declaration, rather than length. As array in VB, like C# are 
            ' zero-based, so the actual length/count becomes 1 extra.
            Dim passwordBin(encPasswordBin.Length - 1) As Byte
            
            cipher.Decrypt _
            ( _
                nonce, _
                encPasswordBin, _
                tagPasswordBin, _
                passwordBin _
            )
            Dim password As String = Encoding.UTF8.GetString(passwordBin, 0, passwordBin.Length)
            Console.WriteLine("Password = {0}", password)
        End Using
    End Sub
    
    Function HexDecode(s As String) As Byte()
        ' NOTE: Need to subtract 1 as VB uses last index in array declaration,  
        ' rather than length. As array in VB, like C# are zero-based, so the 
        ' actual length/count becomes 1 extra.
        Dim bytes(CInt(s.Length / 2) - 1) As Byte
        
        For i As Integer = 0 To bytes.Length-1 Step 1
            Dim b As String = s.Substring(i*2, 2)
            bytes(i) = byte.Parse(b, NumberStyles.HexNumber)
        Next
        
        Return bytes
    End Function
End Module
