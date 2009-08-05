# dependent on CouchExpress::Model being loaded first
module CouchExpress
  class ValidatedModel < CouchExpress::Model 
    include CouchRest::Validation 
    auto_validate!
  
    # Validation Staging -------------------
    # 
    # Since attributes are capable of being more complex data types than in an RBDMS,
    # it is sometimes desirable to add errors during the process on setting variables.
    # CouchRest validation, clears errors and then rebuilds them. Validation Staging
    # saves errors to a temporary location, and hooks them into the validation process
    # when validation is called. 
    
  
    attr_accessor :staged_errors
    def add_staged_error( field, message )
      self.staged_errors ||= {}
      self.staged_errors[field] ||= []
      self.staged_errors[field] << message
    end    
    
    # hook
    validates_with_method :validate_staged 
    def validate_staged
      if staged_errors && !staged_errors.empty?
        while arr = staged_errors.shift do
          field = arr.first
          arr.last.each do |msg| 
            errors.add( field, msg ) 
          end  
        end
        return [ false, nil]  
      else
        true
      end    
    end    
    
  end # ValidatedModel
end # CouchExpress   