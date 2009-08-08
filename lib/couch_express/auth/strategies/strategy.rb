module CouchExpress::Strategy
  def remember_if_requested!
    if ( params['session'] && params['session']['remember_me'] == '1') ||
       ( remembered = current_user.auth['remember_me'] && current_user.auth['remember_me']['expires_at'] >= Time.now )
      user.remember! unless remembered
      cookies[:remember_token] = {  :value   => user.auth['remember_me']['token'],
                                    :expires => user.auth['remember_me']['expires_at'] }
    end  
  end  
end  
