module CouchExpress
  module ControllerAuth 

    def redirect_back(default='/')
      session[:return_to] ||= params[:return_to]
      if session[:return_to]
        redirect_to(session[:return_to])
      else
        redirect_to(default)
      end
      session[:return_to] = nil
    end

    def store_location
      session[:return_to] = request.request_uri if request.get?
    end  
  
  end # ControllerAuth
end # CouchExpress      