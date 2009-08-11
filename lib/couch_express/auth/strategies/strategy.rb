module CouchExpress::Strategy
  # put this is a module and include across all strategies
  def remember_if_requested!( user )
    if params['session'] && params['session']['remember_me'] == '1'
      user.remember_me!
    end  
  end  
  
  # haven't found a way to do this with warden/rack setup
  # def remember_if_requested!( user )
  #   if ( params['session'] && params['session']['remember_me'] == '1') ||
  #      ( remembered = user.auth['remember_me'] && user.remember_expires_at >= Time.now )
  #     user.remember! unless remembered
  #     cookies[:remember_token] = {  :value   => user.auth['remember_me']['token'],
  #                                   :expires => user.auth['remember_me']['expires_at'] }
  #   end  
  # end 
end  
