require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/model_fixtures/validated_model')

describe CouchExpress::ValidatedModel do
  before(:each) do
    User = ValidatedModel unless defined?( User )
    User.delete_all 
    @valid_params = {
      :username => 'rughetto',
      :email => 'ru_ghetto@rubyghetto.com'
    }
  end
  # not going to test everything, just a smattering of the important ones
  # to ensure that couchrest isn't breaking expectations on User
  describe 'CouchRest validations' do
    it 'should be valid with valid params' do 
      user = User.new(@valid_params)
      user.should be_valid
    end  
    
    it 'should validate a property is present' do
      user = User.new( @valid_params.merge(:username => nil) )
      user.should_not be_valid
      user.errors.on(:username).should_not be_nil
    end
      
    it 'should validate with a format' do
      user = User.new( @valid_params.merge(:username => 'ru') )
      user.should_not be_valid
      user.errors.on(:username).should_not be_nil
    end
      
    it 'should validate length of an array' do 
      user = User.new( @valid_params.delete(:email) )
      user.should_not be_valid
      user.errors.on(:emails).should_not be_nil
    end
      
    it 'should validate with a method' do 
      user = User.create!( @valid_params.dup )
      user_2 = User.new( @valid_params.merge(:email => 'new@email.com') ) 
      user_2.should_not be_valid
    end
      
    it 'should attach method validation to the right error key' do 
      pending( 'CouchRest has this wrong! I have a bug in Lighthouse')
      user = User.create!( @valid_params.dup )
      user_2 = User.new( @valid_params.merge(:email => 'new@email.com') ) 
      user_2.errors.on(:username).should_not be_nil
    end  
  end
  
  describe 'Added validations' do
    describe 'staging errors' do 
      it 'should be able to add errors to staging'
      it 'should transfer errors from staged to actual on model validation'
      it 'should staged errors should be empty after model validation'
    end  
  end  
     
end  
    
