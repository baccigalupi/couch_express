module CouchExpress
  class Model < CouchRest::ExtendedDocument 
    
    # Validation Staging -------------------
    include CouchRest::Validation 
  
    attr_accessor :staged_errors
    validates_with_method :validate_staged
    
    def validate_staged
      if staged_errors && !staged_errors.empty?
        while arr = staged_errors.shift do 
          errors.add( arr.first, arr.last )
        end
        return [ false, 'Some validation errors while setting attribute values']  
      else
        true
      end    
    end    
    
    # Changed? -----------------------------
    save_callback :before, :clear_prev
    
    def changed?( key=nil )
      if key
        prev[key] != self[key]
      else
        prev_keys = prev.keys.sort
        current_keys = self.keys.sort
        has_changed = false
        # check to see if the keys match
        if prev_keys != current_keys
          has_changed = true
        else # otherwise check each key value pair
          prev_keys.each do |k|
            if self[k].class == Time
              # for whatever reason time comparisons are failing, maybe it is a micro-second issue
              has_changed = has_changed || prev[k].to_s != self[k].to_s
            else
              has_changed = has_changed || prev[k] != self[k]
            end  
            break if has_changed
          end
        end
        has_changed    
      end    
    end

    private 
      def prev
        @prev ||= self.class.get("#{self.id}")
      end
    
      def clear_prev
        @prev = nil
      end 
    public  
    
    
  end # Model
end # CouchExpress   