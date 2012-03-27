module Encrypt
 def decrypt(password)  
   if self.encrypted_data  
     private_key = OpenSSL::PKey::RSA.new(File.read(App::Config.private_key),password)  
     cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')  
     cipher.decrypt  
     cipher.key = private_key.private_decrypt(self.encrypted_key)  
     cipher.iv = private_key.private_decrypt(self.encrypted_iv)  
  
     decrypted_data = cipher.update(self.encrypted_data)  
     decrypted_data << cipher.final  
   else  
     ''  
   end  
 end  
 
 def clear  
   self.encrypted_data = self.encrypted_key = self.encrypted_iv = nil  
 end  
 
 private  
 
 def encrypt  
   if !self.plain_data.blank?  
     public_key = OpenSSL::PKey::RSA.new(File.read(App::Config.public_key))  
     cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')  
     cipher.encrypt  
     cipher.key = random_key = cipher.random_key  
     cipher.iv = random_iv = cipher.random_iv  
 
     self.encrypted_data = cipher.update(self.plain_data)  
     self.encrypted_data << cipher.final  
 
     self.encrypted_key =  public_key.public_encrypt(random_key)  
     self.encrypted_iv = public_key.public_encrypt(random_iv)  
   end  
 end  
end  
