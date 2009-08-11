require File.dirname(__FILE__) + '/authmodel'
require File.dirname(__FILE__) + '/temporary_token'

module CouchExpress::AuthModel::LostPassword
  def self.included( klass )
    klass.class_eval do
      include CouchExpress::AuthModel
      include CouchExpress::AuthModel::TemporaryToken
      
      include InstanceMethods
      # extend  ClassMethods 
    end  
  end # self.included 
  
  module InstanceMethods
    def send_lost_password_email(email_address=nil)
      email_address = ( email_address && self.emails.include?( email_address ) ) ? email_address : self.email
      UserMailer.deliver_change_password( self, email_address )
    end
    
    def lost_password!(email_address=nil)
      add_temporary_token!
      send_lost_password_email(email_address)
    end    
  end
  
  module ClassMethods
    # nothing to see here!
  end
end  
         