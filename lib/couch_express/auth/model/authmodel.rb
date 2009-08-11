require 'digest/sha1' 

module CouchExpress::AuthModel 
  def self.included( klass ) 
    klass.class_eval do
      property :auth, :default => {'verified' => false}
      
      extend ClassMethods
      include InstanceMethods 
      alias :authenticatable? :authable?  
      
      validates_with_method :has_authentication
    end  
  end 
  
  module InstanceMethods 
    def generate_hash( string )
      Digest::SHA1.hexdigest(string)
    end
    
    def authable?
      !(self.auth.keys - ['remember_me', 'temporary_token', 'verified']).empty? 
    end 
    
    def has_authentication
      authable? ? true : ['false', 'must have one valid authentication method']
    end
    
    def verify!
      verify
      save
    end
    
    def verify
      self.auth['verified'] = true
    end
    
    def verified? 
      self.auth['verified']
    end        
  end # InstanceMethods  
  
  module ClassMethods
    def auth_strategies
      @auth_strategies ||= []
    end 
    
    def add_auth_strategy( sym )
      auth_strategies unless @auth_strategies # to initialize
      @auth_strategies << sym
    end     
  end # ClassMethods    
end   