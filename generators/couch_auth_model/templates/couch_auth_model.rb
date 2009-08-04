require COUCH_EXPRESS + '/couch_express/auth/model/password'

class <%= class_name %> < CouchExpress::ValidatedModel
  include CouchExpress::AuthModel::Password
  
  use_database CouchRest.database!("http://localhost:5984/couch_auth_users_#{RAILS_ENV}")
  
  # Local Schema -------------------------------
  property  :username 
  property  :full_name, :default => {}
  property  :emails, :defalut => []
  timestamps!   
  
  # Validations --------------------------
  validates_present  :username 
  validates_format   :username, 
    :with => /\A[0-9a-z\-]{3,30}\z/, # Alphanumeric plus hyphen, length 3 to 30 
    :message => 'username must be alpha-numeric (hyphen allowed too), ranging from 3 to 30 characters'
        
  validates_with_method :username, :validate_username_unique
  validates_length :emails, :min => 1 

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
  
  def valid_email_format?(e, validate_with_check = true)
     email_name_regex  = '[\w\.%\+\-]+'
     domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
     domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
     email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
     is_valid = e.match( email_regex ) 
     if validate_with_check && !is_valid
       self.staged_errors ||= {}
       self.staged_errors[:emails] =  "Email must have a valid format"
     end 
     is_valid 
  end 
  
  def email_unique?(e, validate_with_check = true)
    is_valid = self.class.by_email( :key => e, :limit => 1).blank? 
    if validate_with_check && !is_valid
      self.staged_errors ||= {}
      self.staged_errors[:emails] = "Added email is not unique"
    end
    is_valid  
  end
  
  # Views --------------------------------
  view_by :updated_at
  view_by :username
  view_by :email,
    :map => 
      "function(doc) {
        if( doc['couchrest-type'] == '<%= class_name %>' && doc.emails ){
          doc.emails.forEach( function(email) {
            emit(email, null);
          });
        }
      }"

  # Accessors ----------------------------
  def email
    emails.first
  end

  def email=( e )
    self.emails ||= []
    if emails.include?( e )
      # move this e to head if already in the set, don't duplicate
      emails.delete( e )
      emails.unshift( e )
    else 
      emails.unshift( e ) if valid_email_format?( e ) && email_unique?( e )
    end  
    email
  end  
  
  def name 
    if full_name
      name = ""
      name << full_name[:first] if full_name[:first]
      name << ' ' if full_name[:last] && full_name[:first]
      name << full_name[:last] if full_name[:last]
    end 
    name 
  end 
  
  def name=( n )
    # this could be a lot more interesting and complicated,
    # mr/ms/dr checking etc.
    if n 
      self.full_name ||= {}
      name_arr = n.split(/\s/)
      case name_arr.size
      when 0
        # do nothing, use default
      when 1
        self.full_name[:first] = name_arr.first
      when 2 
        self.full_name[:first] = name_arr.first
        self.full_name[:last] = name_arr.last 
      else
        self.full_name[:first] = name_arr.shift
        self.full_name[:last] = name_arr.pop
        self.full_name[:middle] = name_arr.join(' ')
      end
    end
    self.full_name   
  end          
  
  def first_name
    full_name[:first] 
  end
  
  def first_name=( n )
    self.full_name ||= {}
    self.full_name[:first] = n
  end  
  
  def last_name
    full_name[:last]
  end 
  
  def last_name=( n )
    self.full_name ||= {}
    self.full_name[:last] = n
  end    
    
end