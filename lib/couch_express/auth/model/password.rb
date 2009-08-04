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
    def authenticate_by_password( login, password )
      user = authenticate_by_username( login, password )  
      user = authenticate_by_email( login, password ) if user.nil? 
      user
    end
      
    def authenticate_by_username( username, password )
      user = by_username( :key => username, :limit => 1 ).first
      user = user.authenticate_by_password( password ) if user
      user
    end
    
    def authenticate_by_email( email, password )
      user = by_email( :key => email, :limit => 1 ).first
      user = user.authenticate_by_password( password ) if user
      user
    end
  end # ClassMethods 
  
  module InstanceMethods
    def authenticate_by_password( password )
      crypted = self.auth && self.auth['password'] && self.auth['password']['encrypted_password']
      encrypt( password ) == crypted ? self : false 
    end  
    
    def password=( p )
      if password_valid?( p )
        self.auth['password'] ||= {}
        initialize_salt( p )
        encrypt_password( p )
      end  
    end
    
    # catches async setting of password and password confirmation   
    # e.g. user.password = 'whatever'; user.password_confirmation = 'whatever'
    # instead of User.new( hash ) on user.update_attributes( hash )
    # also makes sure the password_confirmation is not saved to database
    def password_confirmation=( p )
      # save to params for use by password= (need be)
      add_to_params( :password_confirmation, p )
      # check to see if there are staged errors on password relating to confirmation
      if ( staged_errors && staged_errors[:password] && 
           staged_errors[:password].include?( confirmation_error_message ) &&
           p == express_params[:password] )
        staged_errors.delete(:password) # remove all errors and try again with new data 
        self.password = p  
      end    
    end  
     
    protected
      # generate_hash method is defined in CouchExpress::AuthModel::General 
      # since it is used for many auth strategies 
  
      def password_valid?( p, add_validation_errors=true )
        add_to_params( :password, p )
        is_valid = true
        unless p.match(/.{3,40}/)
          is_valid = false 
          add_staged_error( :password, 'Password must be between 3 and 40 characters long') 
        end 
        
        confirmation = express_params && express_params[:password_confirmation]
        unless confirmation && confirmation == p
          is_valid = false
          add_staged_error( :password, confirmation_error_message )
        end  
        is_valid 
      end
      
      def confirmation_error_message
        'Password must match confirmation'
      end  
      
      def encrypt(string)
        generate_hash("--#{auth['password']['salt']}--#{string}--") if auth['password'] && auth['password']['salt']
      end 
    
      def initialize_salt( p )
        if new_record?
          self.auth['password']['salt'] = generate_hash("--#{Time.now.utc.to_s}--#{p}--")
        end
      end
    
      def encrypt_password( p )
        self.auth['password']['encrypted_password'] = encrypt( p )
      end   
    public     
    
  end # InstanceMethods
end  