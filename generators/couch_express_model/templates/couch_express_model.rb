class <%= class_name %> < CouchExpress::ValidatedModel
  use_database CouchRest.database!("http://localhost:5984/my_database_#{RAILS_ENV}") # change this to match your database
  
  # Schema -------------------------------
  <% if verbose -%># unique_id :custom_generated_id<% end -%> 
  property  :my_property
  timestamps!
  
  <% if verbose -%># Validations -------------------------- 
  # Sample validations: more info available in the couchrest docs, specs and code  
  # validates_present        :my_property
  # validates_is_confirmed   :password,   :if => proc {|r| r.password_required? }
  # validates_length         :email,      :within => 3..100
  # validates_format         :email,      :as => :email_address
  <% end -%>
 
  # Views --------------------------------
  view_by :my_property
 
  <% if verbose -%># Callbacks ---------------------------- 
  # Sample callbacks/hooks: more information available in the couchrest docs, specs and code  
  # save_callback :before, :do_something_before_save 
  <% end -%> 
  
end