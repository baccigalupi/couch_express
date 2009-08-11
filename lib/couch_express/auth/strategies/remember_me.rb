module CouchExpress::Strategy
  module RememberMe
    def valid? 
      puts 'in RememberMe#valid?'
      puts (self.request.cookies.methods - Object.new.methods).inspect 
      puts (self.request.cookies.keys).inspect
      request.cookies.keys.include?( 'remember_token' )
    end
    
    def authenticate!
      token = request.cookies['remember_token'] 
      if user = User.authenticate_by_remember_me( token )
        success!( user) 
      else
        if ( user == false )
          message = 'Remember me time period has expired. Please login again.'
        else
          message = 'User not found'
        end    
        fail!( message )
      end   
    end  
  end    
end       