require 'digest/sha1' 

module CouchExpress::AuthModel 
  def self.included( klass ) 
    klass.class_eval do
      property :authentication, :default => {}
      extend ClassMethods
    end  
  end
  
  module ClassMethods
    def generate_hash( str )
      Digest::SHA1.hexdigest(string)
    end
    
    def auth_strategies
      @auth_strategies ||= []
    end 
    
    def add_auth_strategy( sym )
      @auth_strategies << sym
    end     
  end # ClassMethods    
end   