class Model < CouchExpress::Model 
  use_database DB # setup in spec_helper
  
  property :string
  # property :integer, :cast_as => 'Fixnum'  # this doesn't yet work because casting expects class to respond to #new
  property :array
  timestamps! 
  
  save_callback :before, :halt_for_throwing
  def halt_for_throwing
    raise(ArgumentError, 'Something went very wrong!') if self[:throw_me] == true  
  end   
  
end  