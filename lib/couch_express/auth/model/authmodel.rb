require 'digest/sha1' 

module CouchExpress::AuthModel 
  def self.included( klass ) 
    klass.class_eval do
      property :authentication, :default => {}
      extend ClassMethods
      include InstanceMethods
    end  
  end 
  
  module InstanceMethods 
    def generate_hash( string )
      Digest::SHA1.hexdigest(string)
    end
  end # InstanceMethods  
  
  module ClassMethods
    def auth_strategies
      @auth_strategies ||= []
    end 
    
    def add_auth_strategy( sym )
      auth_strategies # to initialize
      @auth_strategies << sym
    end     
  end # ClassMethods    
end   