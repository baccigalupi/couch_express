require File.dirname(__FILE__) + '/authmodel'

module CouchExpress::AuthModel::Password
  def self.included( klass )
    klass.class_eval do
      include CouchExpress::AuthModel
      include InstanceMethods
      extend  ClassMethods 
      
      # validates_is_confirmed   :password,   :if => proc {|r| r.password_required? }
      # validates_present        :term_agreement, :message => ": You must agree to the Terms of Use.",   :if => proc {|r| r.new_record? }
    end  
  end # self.included 
  
  module ClassMethods
    # generate_hash method is defined in CouchExpress::AuthModel::General 
    # since it is used for many auth strategies 
  end # ClassMethods 
  
  module InstanceMethods
    def password=( p )
      if p == delete(:password_confirmed)
        self.authentication[:password] ||= {}
        initialize_salt
        encrypt_password( p )
      else
          
      end  
    end
    
    def encrypt(string)
      generate_hash("--#{salt}--#{string}--")
    end 
    
    def initialize_salt
      if new_record?
        self.authentication[:password][:salt] = self.class.generate_hash("--#{Time.now.utc.to_s}--#{password}--")
      end
    end

    def encrypt_password( p )
      self.authentication[:password][:encrypted_password] = encrypt( p )
    end
  end # InstanceMethods
end  