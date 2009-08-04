require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe <%= class_name %> do
  before(:each) do
    <%= class_name %>.delete_all
     
    @valid_attributes = {
      :username => 'rughetto',
      :password => 'secret',
      :password_confirmation => 'secret',
      :emails => ['ru_ghetto@rubyghetto.com', 'baccigalupi@gmail.com']
    }
  end
  
  describe 'validation' do
    it 'should be valid with valid params' do 
      user = <%= class_name %>.new(@valid_attributes)
      user.valid?.should == true
    end  
    
    it 'must have a username' do 
      params = @valid_attributes.reject{|key, val| key == :username}
      user = <%= class_name %>.new( params )
      user.should_not be_valid
      user.errors.on(:username).should_not be_nil
    end  
    
    it 'username must be a lowercase alhpanumeric string with optional hyphens' do 
      ['there is space', 'Iñtërnâtiônàlizætiøn', 'semicolon;', 
        'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', "tab\t", "newline\n"].each do |username| 
        user = <%= class_name %>.new( @valid_attributes.merge(:username => username ) )
        user.should_not be_valid
        user.errors.on(:username).should_not be_nil
      end    
    end
    
    it 'username should be unique' do
      user = <%= class_name %>.create!( @valid_attributes.dup )
      user_2 = <%= class_name %>.new( :username => @valid_attributes[:username], 
        :password => 'secret', :password_confirmation => 'secret',
        :emails => ['kane@trajectorset.com']
      )
      user_2.should_not be_valid
      # couchrest is not working as anticipated because the error 
      # is being attached to the method name, not the username field. 
      # So this is commented out until there is some resolution
      # user_2.errors.on(:username).should_not be_nil
    end 
    
    it 'username should be valid on resave' do 
      user = <%= class_name %>.create!( @valid_attributes ) 
      user.email = 'kane@trajectorset.com'
      lambda{ user.save! }.should_not raise_error
    end   
      
    it 'must have at least one email' do
      params = @valid_attributes.reject{|key, value| key == :emails}
      user = <%= class_name %>.new( params )
      user.should_not be_valid
      user.errors.on(:emails).should_not be_nil
    end
    
    describe 'authentication' do 
      
      it 'authable?/authenticatable? must be true' do 
        user = <%= class_name %>.new( @valid_attributes.dup )
        user.should be_authable 
        user.should be_valid 
        
        @valid_attributes.delete(:password)
        @valid_attributes.delete( :password_confirmation )
        user_2 = <%= class_name %>.new( @valid_attributes )
        user_2.should_not be_authable
        user_2.should_not be_valid
      end  
      
      describe 'password' do
        it 'password should not be required' do
          @valid_attributes.delete( :password )
          @valid_attributes.delete( :password_confirmation )
          user = <%= class_name %>.new( @valid_attributes )
          user.auth[:new_method] = true
          user.should be_authable
          user.should be_valid
        end  
    
        it 'should require a password confirmation when setting password' do
          @valid_attributes.delete( :password_confirmation )
          user = <%= class_name %>.new( @valid_attributes ) 
          user.should_not be_valid
        end  
      
        it 'should be valid when the password_confirmation preceeds the password' do 
          user = <%= class_name %>.new( {
            :password_confirmation => 'secret',
            :username => 'rughetto',
            :password => 'secret',
            :emails => ['ru_ghetto@rubyghetto.com', 'baccigalupi@gmail.com']
          })
          user.should be_valid
        end    
      
        it 'password should match confirmation when using password' do 
          user = <%= class_name %>.new( {
            :password_confirmation => 'not_secret',
            :username => 'rughetto',
            :password => 'secret',
            :emails => ['ru_ghetto@rubyghetto.com', 'baccigalupi@gmail.com']
          })
          user.should_not be_valid 
        end  
      end  
    end
  end
  
  describe 'authentication' do
    it 'should have an auth attribute' do
      user = <%= class_name %>.new
      user.keys.should include('auth')
    end  
    
    describe 'password' do
      describe 'on record create' do
        before(:each) do
          @user = <%= class_name %>.create!( @valid_attributes )
        end   
        
        it 'should add a "password" hash to the auth attribute' do 
          @user.auth['password'].should_not be_nil
        end
          
        it 'should add "salt" and "encrypted_password" key/values to the authentication["password"] hash' do 
          @user.auth['password']['salt'].should_not be_nil
          @user.auth['password']['encrypted_password']
        end
      end
      
      describe 'on change' do 
        before(:each) do
          @user = <%= class_name %>.create!( @valid_attributes )
        end   
        
        it 'should not save a new encrpted_password if the password is not valid' do 
          pass = @user.auth['password']['encrypted_password'].dup
          @user.password_confirmation = 'something'
          @user.password = 'else'
          @user.auth['password']['encrypted_password'].should == pass
        end
          
        it 'should change the encrypted_password if all is good' do
          pass = @user.auth['password']['encrypted_password'].dup
          @user.password = 'something'
          @user.password_confirmation = 'something'
          @user.auth['password']['encrypted_password'].should_not == pass    
        end  
      end
      
      describe 'instance method #authenticate_by_password' do 
        before(:each) do
          @user = <%= class_name %>.create!( @valid_attributes )
        end
          
        it 'should #authenticate_by_password, returning a user' do 
          @user.authenticate_by_password('secret').should == @user
        end 
         
        it 'should return false when #authenticate_by_password gets a bad password' do
          @user.authenticate_by_password('not_secret').should == false
        end  
      end  
        
      describe "class method #authenticate_by_email" do
        before(:each) do
          @user = <%= class_name %>.create!( @valid_attributes )
        end  
        
        it 'should return a user when given a valid email and password' do 
          <%= class_name %>.authenticate_by_email('ru_ghetto@rubyghetto.com', 'secret').should == @user
          <%= class_name %>.authenticate_by_email('baccigalupi@gmail.com', 'secret').should == @user
        end
          
        it 'should return nil when user is not found' do
          <%= class_name %>.authenticate_by_email('kane@trajectorset.com', 'secret').should == nil
        end
         
        it 'should return false when user is found but password is bad' do 
          <%= class_name %>.authenticate_by_email('baccigalupi@gmail.com', 'not secret!').should == false
        end  
      end  
      
      describe "class method #authenticate_by_username" do
        before(:each) do
          @user = <%= class_name %>.create!( @valid_attributes )
        end  
        
        it 'should return a user when given a valid username and password' do 
          <%= class_name %>.authenticate_by_username( 'rughetto', 'secret' ).should == @user
        end 
        
        it 'should return nil when user is not found' do 
          <%= class_name %>.authenticate_by_username('kane', 'baccigalupi').should == nil
        end 
         
        it 'should return false when user is found but password is bad' do 
          <%= class_name %>.authenticate_by_username('rughetto', 'not secret!').should == false
        end  
      end
      
      describe "class method #authenticate_by_password" do
        before(:each) do
          @user = <%= class_name %>.create!( @valid_attributes )
        end  
        
        it 'should try to authenticate via username' do
          <%= class_name %>.authenticate_by_password( 'rughetto', 'secret' ).should == @user
        end
          
        it 'should try to authenticate via email' do
          <%= class_name %>.authenticate_by_password( 'ru_ghetto@rubyghetto.com', 'secret' ).should == @user 
          <%= class_name %>.authenticate_by_password( 'baccigalupi@gmail.com', 'secret' ).should == @user
        end
          
        it 'should return nil if user is not found' do
          <%= class_name %>.authenticate_by_password('kane@trajectorset.com', 'secret').should == nil
          <%= class_name %>.authenticate_by_password('kane', 'secret').should == nil
        end  
        
        it 'should return false if user is found but password is bad' do
          <%= class_name %>.authenticate_by_password('ru_ghetto@rubyghetto.com', 'not secret!').should == false
          <%= class_name %>.authenticate_by_password('baccigalupi@gmail.com', 'not secret!').should == false
          <%= class_name %>.authenticate_by_password('rughetto', 'not secret!').should == false
        end  
      end     
    end  
  end        

  describe 'faux activerecord munges' do 
    describe 'create!' do
      # these methods has been added to couchrest, 
      # so it is here just to ensure forward compatibility
      # rspec, especially since uses Klass.create! when building an model spec
    
      it 'should create!' do
        lambda {
          <%= class_name %>.create!( @valid_attributes )
        }.should_not raise_error
      end
    
      it 'create! should save and return the record on success' do
        u = <%= class_name %>.create!( @valid_attributes )
        u.should_not be_nil
        u.should_not be_new_record
        u.username.should == 'rughetto'
      end
      
      it 'create! should throw an error on failure to save' do
        @valid_attributes.delete(:username) 
        lambda { <%= class_name %>.create!( @valid_attributes ) }.should raise_error
      end 
    end
    
    describe 'equality ==' do
      it 'a saved document should be == to the document subsequently pulled (unchanged) from the database' do
        user = <%= class_name %>.create!( @valid_attributes )
        user.should == <%= class_name %>.get( user.id )
      end  
    end  
  end 
  
  describe 'changed?' do
    before(:each) do
      @user = <%= class_name %>.new( @valid_attributes )
    end  
    
    it 'should return true when new record' do
      @user.should be_changed
    end  
    
    it 'should return true when record is saved and then an attribute has changed' do
      @user.save
      @user.username = 'gus'
      @user.should be_changed
    end
      
    it 'should return false when record is saved and no attributes have been altered' do
      @user.save
      @user.should_not be_changed
    end
      
    it 'should take a valid attribute key as an argument and return true if that attribute has changed' do
      @user.save
      @user.username = 'gus'
      @user.changed?(:username).should be_true
    end
      
    it 'should take a valid attribute key as an argument and return false in that attribute is the same' do
      @user.save
      @user.changed?(:username).should be_false
    end  
    
    it 'should take an invalid attribute key and return false' do
      @user.save
      @user.changed?(:garbage).should be_false
    end
      
    it 'should not persist an attribute for the method and value of "prev"' do
      @user.save
      @user.username = 'gus'
      @user.changed?
      @user.save
      @user[:prev].should == nil
    end  
  end 
  
  describe 'getters and setters' do 
    describe 'names' do
      before(:each) do
        @name_params = @valid_attributes.merge( :name => 'Kane Baccigalupi' )
        @user = <%= class_name %>.new( @name_params ) 
      end
      
      it 'should have a name' do
        @user.name.should == 'Kane Baccigalupi'
      end
    
      it 'should have a first name' do
        @user.first_name.should == 'Kane'
      end
    
      it 'should have a last name' do
        @user.last_name.should == 'Baccigalupi'
      end
    
      it 'should be able to set individual name directly' do
        user = <%= class_name %>.new
        user.first_name = 'Kane'
        user.first_name.should == 'Kane'
        user.name.should == 'Kane'
        user.last_name = 'Baccigalupi'
        user.last_name.should == 'Baccigalupi'
        user.name.should == 'Kane Baccigalupi'
      end
    end
    
    describe 'emails' do
      before(:each) do
        @user = <%= class_name %>.new( @valid_attributes.dup )
      end
      
      it '#email should return the first email in emails' do 
        @user.email.should == 'ru_ghetto@rubyghetto.com'
      end
        
      it '#email should add the passed email to the top of emails' do
        new_email = "kane@trajectorset.com"
        @user.email =  new_email
        @user.emails.should include( new_email ) 
        @user.email.should == new_email
      end 
      
      it '#email should not add a duplicate email to emails array' do
        email = @valid_attributes[:emails].last.dup
        @user.email = email
        @user.emails.size.should == @valid_attributes[:emails].size
      end
        
      it '#email should movie an existing email to the top of emails' do
        email = @valid_attributes[:emails].last.dup
        @user.email = email
        @user.emails.first.should == email
      end
        
      it '#email should invalidate model if email format in not valid' do 
        email = "i'm not valid"
        @user.email = email
        @user.should_not be_valid
        @user.errors.on(:emails).should_not be_nil 
      end  
      
      it '#email should not add email to emails if format is invalid' do
        email = "i'm not valid"
        @user.email = email
        @user.emails.size.should == @valid_attributes[:emails].size
        @user.emails.should_not include( email )
      end
        
      it '#email should invalidate model if email is not unique outside the current record' do
        @user.save
        user = <%= class_name %>.new(
          :username => 'rue',
          :password => 'secret',
          :password_confirmation => 'secret',
          :emails => ['kane@trajectorset.com'] 
        ) 
        dup_email = 'baccigalupi@gmail.com'
        user.email = dup_email 
        user.should_not be_valid
        user.errors.on(:emails).should_not be_nil
      end 
        
      it '#email should not add email to email if it is not unique' do
        @user.save
        user = <%= class_name %>.new(
          :username => 'rue',
          :password => 'secret',
          :password_confirmation => 'secret',
          :emails => ['kane@trajectorset.com'] 
        ) 
        dup_email = 'baccigalupi@gmail.com'
        user.email = dup_email
        user.emails.should_not include( dup_email )
      end  
      
    end      
  end       
  
end
