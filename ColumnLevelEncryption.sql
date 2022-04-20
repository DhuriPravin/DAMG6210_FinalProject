
-----/** Column Level Encryption Begins **/-------------

--Creation of Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P455w0rd';   

--Creation of Certificate
CREATE CERTIFICATE EncryptionCert WITH SUBJECT = 'Certificate for column level encryption'; 

--Check if Certificate Got Created
SELECT name, pvt_key_encryption_type_desc FROM sys.certificates


--Creation of Symmetric Key
CREATE SYMMETRIC KEY EncryptionKey WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE EncryptionCert  

--Check if 2 rows exists in the symmetric key table, one is default key and the other is the one we created
SELECT name, algorithm_desc FROM sys.symmetric_keys

----Open and Close Statements of Symmetric keys to execute before performing something related to Encryption
-- OPEN SYMMETRIC KEY EncryptionKey DECRYPTION BY CERTIFICATE EncryptionCert
-- CLOSE SYMMETRIC KEY EncryptionKey

-----Sample Statements to Insert by encrypting and Fetching by Decrypting
-- INSERT INTO loginDetails VALUES  ('test','Check@23', ENCRYPTBYKEY(KEY_GUID('EncryptionKey'),'Check@23'))
-- SELECT  CAST(DECRYPTBYKEY(passwordEncrypted) AS VARCHAR) FROM loginDetails

-----/** Column Level Encryption Ends **/-------------