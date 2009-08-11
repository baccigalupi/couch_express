module CouchExpress::Strategy
  module TemporaryToken
    def valid? 
      params['token']
    end
    
    def authenticate!
      token = params['token'] 
      if user = User.authenticate_by_temporary_token( token )
        success!( user) 
      else
        if ( user == false )
          message = "Hmmm, it has been a while since you set this us. Your token has expired. Let's do it again."
        else
          message = 'User not found'
        end    
        fail!( message )
      end   
    end  
  end    
end       