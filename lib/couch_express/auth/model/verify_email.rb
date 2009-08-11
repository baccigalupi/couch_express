require File.dirname(__FILE__) + '/authmodel'
require File.dirname(__FILE__) + '/temporary_token'

module CouchExpress::AuthModel::VerifyEmail
  # this verifies only the first in the list of emails stored
  # different logic would be required to authorize all email addresses 
  
  def self.included( klass )
    klass.class_eval do
      include CouchExpress::AuthModel
      include CouchExpress::AuthModel::TemporaryToken
      
      include InstanceMethods
      # extend  ClassMethods 
      
      save_callback :before,  :set_verification_token 
      save_callback :before,  :send_email_verification
    end  
  end # self.included 
  
  module InstanceMethods
    def send_email_verification
      # this should be conditional on the absence of auth strategies 
      # like openid and facebook, which do this work for us
      # probably these should verify, on creation
      UserMailer.deliver_verify_email( self ) if new_record? && valid? && !verified?
    end
    
    def set_verification_token 
      add_temporary_token if new_record? && !verified?
    end  
  end
  
  module ClassMethods
    # nothing to see here!
  end
end   