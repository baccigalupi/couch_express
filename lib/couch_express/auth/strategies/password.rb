require File.dirname(__FILE__) + 'strategy' 

Warden::Strategies.add(:password) do
  
  include CouchExpress::Strategy
  
  def valid?
    params['session'] && 
    params['session']['password'] && 
    (params['session']['username'] || params['session']['email'] || params['session']['login'] ) 
  end
    
  def authenticate!
    login = params['session']['login'] || params['session']['username'] || params['session']['email'] 
    if user = RailsWarden.default_user_class.authenticate_by_password( login, params['session']['password'] )
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

end # Warden::Strategies