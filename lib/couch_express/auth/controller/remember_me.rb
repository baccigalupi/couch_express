module CouchExpress
  module ControllerAuth 
    module RememberMe 
      def forget_me!
        clear_remember_token
        current_user.forget_me!
      end  
  
      def add_remember_token
        cookies[:remember_token] = {   
          :value   => current_user.auth['remember_me']['token'],
          :expires => current_user.auth['remember_me']['expires_at']
        } if current_user.auth['remember_me']
      end
  
      def clear_remember_token
        cookies.delete :remember_token
      end
    end # RememberMe        
  end # ControllerAuth
end # CouchExpress::ControllerAuth 
