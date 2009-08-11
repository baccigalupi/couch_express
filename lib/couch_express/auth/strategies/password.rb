require COUCH_EXPRESS + '/couch_express/auth/strategies/strategy' 

module CouchExpress::Strategy
  module Password
    include CouchExpress::Strategy 
    def valid?
      params['session'] && 
      params['session']['password'] && 
      (params['session']['username'] || params['session']['email'] || params['session']['login'] ) 
    end
    
    def authenticate!
      login = params['session']['login'] || params['session']['username'] || params['session']['email'] 
      if user = User.authenticate_by_password( login, params['session']['password'] )
        remember_if_requested!( user )
        success!( user) 
      else
        if ( user == false )
          message = 'Password incorrect'
        else
          message = 'User not found'
        end    
        fail!( message )
      end   
    end  
  end    
end  