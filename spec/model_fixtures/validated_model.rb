class ValidatedModel < CouchExpress::ValidatedModel 
  use_database DB # setup in spec_helper
  
  # PROPERTIES -----------------------------------
  property  :username
  property  :emails, :default => []
  
  # VIEWS ----------------------------------------
  view_by :username
  view_by :email,
    :map => 
      "function(doc) {
        if( doc['couchrest-type'] == 'User' && doc.emails ){
          doc.emails.forEach( function(email) {
            emit(email, null);
          });
        }
      }"
  
  # NORMAL COUCHREST VALIDATIONS -----------------
  validates_present  :username 
  validates_format   :username, 
    :with => /\A[0-9a-z\-]{3,30}\z/, # Alphanumeric plus hyphen, length 3 to 30 
    :message => 'Username must be alpha-numeric (hyphen allowed too), ranging from 3 to 30 characters'
  
  validates_with_method :username, :validate_username_unique
  def validate_username_unique
    if new_record? || changed?(:username) 
      if self.class.by_username( :key => self.username, :limit => 1).blank?
        return true
      else 
        return [false, "Username has already been taken"] 
      end 
    else
      return true
    end    
  end  
  
  validates_length :emails, :min => 1, :message => 'At least one valid email is required' 
  
  # COUCH_EXPRESS ADDED VALIDATIONS -------------------
  def email=( e )
    emails << e if email_unique?( e )
  end 
  
  def email_unique?( e )
    is_valid = self.class.by_email( :key => e, :limit => 1).blank? 
    if !is_valid
      self.staged_errors ||= {}
      self.staged_errors[:emails] = "Email is not unique"
    end
    is_valid  
  end 
  
end  