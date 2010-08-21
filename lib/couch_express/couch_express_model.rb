module CouchExpress
  class Model < CouchRest::ExtendedDocument 
    if url = CouchExpress.database_url
      use_database url
    end
    
    
    # Param Protection ---------------------
    # In CouchRest, the ExtendedDocument is very public. Anything that is initialized in is 
    # made part of the data, unless there exists some setter methods that catch the initialization params
    # and process the data differently. The methods in this section hope to add some protections and also
    # isolate the params passed in as an instance variable for reference throughout the initialization
    # setting and getting.
    
    attr_accessor :express_params 
    
    def add_to_params( key, value )
      self.express_params ||= {}
      express_params[key] = value
    end  
    
    def initialize( hash={} )
      self.express_params = (hash || {}).dup # because the extended doc seems to consume the hash
      super( hash )
    end
    
    def self.update_attributes_without_saving( hash={} )
      self.express_params = (hash || {}).dup
      super( hash )
    end     
     
    
    save_callback :after, :clear_wrappers 
    def clear_wrappers
      self.express_params = nil
      @prev = nil
      true # so the process doesn't stop
    end
    
    # Equality Fix ---------------------------
    # for some reason == comparison between seemingly identical objects is failing
    def ==( doc )
      doc_keys = doc.keys.sort
      current_keys = self.keys.sort
      is_same = true
      # check to see if the keys match
      if doc_keys != current_keys
        is_same = false
      else # otherwise check each key value pair
        doc_keys.each do |k|
          if self[k].class == Time
            # for whatever reason time comparisons are failing, maybe it is a micro-second issue
            is_same = is_same && doc[k].to_s == self[k].to_s
          else
            is_same = is_same && doc[k] == self[k]
          end  
          break unless is_same
        end
      end
      is_same 
    end    
    
    # Conveniences -------------------------
    def self.delete_all
      all.each {|doc| doc.destroy }
    end
    
    # self.create and self.create! have been rolled into CouchRest
    
    # beware! this only works for finding a single id. So, AR style finds like
    #  User.find([id_1, id_2, ...]) # WON'T WORK !!!
    #  User.find(:all, :conditions => {...}) # WON'T WORK !!!
    # This has been added to make the resources typically generated work relatively painlessly
    # Correct Usage:
    #   User.find( 'id...' ) # Same as User.get( 'id...' )
    def self.find( id ) 
      self.get( id )
    end  
    
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
    #
    def changed?( key=nil )
      if key
        if prev[key].class == Time || self[key].class == Time
          prev[key].to_s != self[key].to_s
        else  
          prev[key] != self[key]
        end  
      else
        self != prev    
      end    
    end

    private 
      def prev
        @prev ||= self.class.get("#{self.id}")
      end
    public 
    
    if defined?( Rails )
      def logger
        RAILS_DEFAULT_LOGGER
      end  
    end   
    
    
  end # Model
end # CouchExpress   