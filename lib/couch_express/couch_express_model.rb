module CouchExpress
  class Model < CouchRest::ExtendedDocument 
    
    # Changed? ----------------------------- 
    #
    # Lazy lightweight implementation of record changed facility. 
    # If a call to any of the changed? methods comes in it requests its record 
    # from the database and does a comparison. The queried record is saved 
    # in an instance variable for future use, and cleared after save.
    #
    # Usage: 
    #  my_model.changed? # checks to see if any attributes were added, deleted or changed
    #  my_model.changed?( :attribute ) # checks to see if an particular attribute changed   save_callback :before, :clear_prev
    
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