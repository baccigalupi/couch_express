require File.dirname(__FILE__) + '/authmodel'

module CouchExpress::AuthModel::RememberMe
  def self.included( klass )
    klass.class_eval do
      include CouchExpress::AuthModel
      include InstanceMethods
      extend  ClassMethods 
      
      view_by :remember_me_token,
      :map => 
        "function(doc) {
          if( doc['couchrest-type'] == '#{RailsWarden.default_user_class}' && 
              doc.auth && doc.auth.remember_me && doc.auth.remember_me.token ){
            emit( doc.auth.remember_me.token, null ); 
          }                           
        }" 
      
      add_auth_strategy( :remember_me )
    end  
  end # self.included 
   
  module ClassMethods
    def authenticate_by_remember_me( token ) 
      user = by_remember_me_token(:key => token, :limit => 1).first
      user ? user.authenticate_by_remember_me : nil
    end  
  end # ClassMethods 

  module InstanceMethods
    def authenticate_by_remember_me
      remember_expires_at && remember_expires_at > Time.now ? self : false 
    end
    
    def remember_expires_at
      expiry = self.auth && self.auth['remember_me'] && self.auth['remember_me']['expires_at']
      if expiry.class == String
        expiry ? Time.parse( expiry ) : nil
      else
        expiry
      end     
    end  
    
    def remember_me( expiry=2.weeks.from_now )
      self.auth['remember_me'] ||= {}
      self.auth['remember_me']['expires_at'] = expiry  
      self.auth['remember_me']['token'] = encrypt("--#{self.auth['remember_me']['expires_at']}--#{self.id}--")
    end
  
    def remember_me!( expiry=2.weeks.from_now )
      remember_me( expiry )
      save
    end

    def forget_me
      self.auth.delete('remember_me')
    end
  
    def forget_me!
      forget_me
      save
    end  
  end # InstanceMethods
   
end # module