require File.dirname(__FILE__) + '/authmodel'

module CouchExpress::AuthModel::Password
  def self.included( klass )
    klass.class_eval do
      include CouchExpress::AuthModel
      include InstanceMethods
      extend  ClassMethods 
      
      add_auth_strategy( :password )
    end  
  end # self.included 
  
  module ClassMethods
    # generate_hash method is defined in CouchExpress::AuthModel::General 
    # since it is used for many auth strategies 
  end # ClassMethods 
  
  module InstanceMethods
    def password=( p )
      if password_valid?( p )
        self.authentication['password'] ||= {}
        initialize_salt( p )
        encrypt_password( p )
      end  
    end
    
    # this assumes password appears before password_confirmation in the params hash;
    # it may not be true :(
    # A better approach would probably be to have two password fields where the name is postfixed with []
    # Then an array would be passed to password and it could confirm that they are both identical and have
    # the right characteristics. But it would involve some manual hacking on the form
    def password_confirmation=( p )
      crypted = self.authentication && self.authentication['password'] && self.authentication['password']['encrypted_password']
      unless crypted && crypted == encrypt( p )
        # remove crypted password
        self.authentication['password'].delete('encrypted_password')
        add_staged_error( :password, 'Password must match confirmation')
      end    
    end  
     
    protected
      def password_valid?( p, add_validation_errors=true )
        is_valid = true
        unless p.match(/.{3,40}/)
          is_valid = false 
          add_staged_error( :password, 'Password must be between 3 and 40 characters long') 
        end
        is_valid 
      end
      
      def encrypt(string)
        generate_hash("--#{authentication['password']['salt']}--#{string}--") if authentication['password'] && authentication['password']['salt']
      end 
    
      def initialize_salt( p )
        if new_record?
          self.authentication['password']['salt'] = generate_hash("--#{Time.now.utc.to_s}--#{p}--")
        end
      end
    
      def encrypt_password( p )
        self.authentication['password']['encrypted_password'] = encrypt( p )
      end   
    public     
    
  end # InstanceMethods
end  