class <%= class_name %> < CouchExpress::Model
  use_database SERVER.default_database # change this to match your database
  
  include CouchRest::Validation <% if verbose -%># delete or comment out for non-validated models
  # include CouchRest::CastedModel # uncomment to cast this model into another document/model <% end -%>
  
  
  # Schema -------------------------------
  <% if verbose -%># unique_id :custom_generated_id<% end -%> 
  property  :my_property
  timestamps!
  
  <% if verbose -%># Validations --------------------------
  # validates_present        :my_property
  # validates_is_confirmed   :password,   :if => proc {|r| r.password_required? }
  # validates_length         :email,      :within => 3..100
  # validates_format         :email,      :as => :email_address
  # validates_present        :term_agreement, :message => ": You must agree to the Terms of Use.",   :if => proc {|r| r.new_record? }
  <% end -%>
 
  # Views --------------------------------
  view_by :my_property
 
  <% if verbose -%># Callbacks ----------------------------
  # save_callback :before, :do_something_before_save 
  <% end -%>
  
end