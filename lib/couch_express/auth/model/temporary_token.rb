require File.dirname(__FILE__) + '/authmodel'

module CouchExpress::AuthModel::TemporaryToken
  def self.included( klass )
    klass.class_eval do
      include CouchExpress::AuthModel
      include InstanceMethods
      extend  ClassMethods 
      
      view_by :temporary_token,
      :map => 
        "function(doc) {
          if( doc['couchrest-type'] == 'User' && 
              doc.auth && doc.auth.temporary_token && doc.auth.temporary_token.token ){
            emit( doc.auth.temporary_token.token, null ); 
          }                           
        }" 
      
      add_auth_strategy( :temporary_token )
    end  
  end # self.included 
  
  module InstanceMethods
    def authenticate_by_temporary_token
      temporary_token_expires_at && temporary_token_expires_at > Time.now ? self : false
    end
    
    def temporary_token_expires_at
      expiry = self.auth && self.auth['temporary_token'] && self.auth['temporary_token']['expires_at']
      if expiry.class == String
        expiry ? Time.parse( expiry ) : nil
      else
        expiry
      end     
    end  
    
    def add_temporary_token( expiry=24.hours.from_now )
      self.auth['temporary_token'] ||= {}
      self.auth['temporary_token']['expires_at'] = expiry  
      self.auth['temporary_token']['token'] = encrypt("--#{self.auth['temporary_token']['expires_at']}--#{self.id}--")
    end
  
    def add_temporary_token!( expiry=24.hours.from_now )
      add_temporary_token( expiry )
      save
    end

    def clear_temporary_token
      self.auth.delete('temporary_token')
    end
  
    def clear_temporary_token!
      clear_temporary_token
      save
    end       
    
  end # InstanceMethods
  
  module ClassMethods 
    def authenticate_by_temporary_token( token ) 
      user = by_temporary_token(:key => token, :limit => 1).first
      user ? user.authenticate_by_temporary_token : nil
    end 
  end # ClassMethods

end # CouchExpress::TemporaryToken     
