require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/model_fixtures/model')

describe CouchExpress::Model do
  before(:each) do
    @params = {
      :string => "I am a string",
      :integer => '0',
      :array => ['1','2','3'] 
   }   
  end
    
  describe 'AR method conveniences' do 
    # these make it easier to work with the expectations of rspec, other packages and users
    
    describe 'create!' do
      # #create and #create! methods have been added to couchrest, 
      # so it is here just to ensure forward compatibility
      it 'should create!' do
        lambda {
          Model.create!( @params )
        }.should_not raise_error
      end
    
      it 'create! should save and return the record on success' do
        model = Model.create!( @params )
        model.should_not be_nil
        model.should_not be_new_record
        model.string.should == 'I am a string'
      end
      
      it 'create! should throw an error on failure to save' do
        lambda { Model.create!( @params.merge!( :throw_me => true ) ) }.should raise_error
      end 
    end
  end
  
  describe 'equality ==' do
    it 'a saved document should be == to the document subsequently pulled (unchanged) from the database' do
      model = Model.create!( @params )
      model.should == Model.get( model.id )
    end  
  end
  
  describe 'changed?' do
    before(:each) do
      @model = Model.new( @params )
    end  
    
    it 'should return true when new record' do
      @model.should be_changed
    end  
    
    it 'should return true when record is saved and then an attribute has changed' do
      @model.save
      @model.string = 'gus'
      @model.should be_changed
    end
      
    it 'should return false when record is saved and no attributes have been altered' do
      @model.save
      @model.should_not be_changed
    end
      
    it 'should take a valid attribute key as an argument and return true if that attribute has changed' do
      @model.save
      @model.string = 'gus'
      @model.changed?(:string).should be_true
    end
      
    it 'should take a valid attribute key as an argument and return false in that attribute is the same' do
      @model.save
      @model.changed?(:string).should be_false
    end  
    
    it 'should take an invalid attribute key and return false' do
      @model.save
      @model.changed?(:garbage).should be_false
    end
      
    it 'should not persist an attribute for the method and value of "prev"' do
      @model.save
      @model.string = 'gus'
      @model.changed?
      @model.save
      @model[:prev].should == nil
    end  
  end          

  describe 'using database config by default' do
    it 'should automatically use the database configuration for development if it exists' do
      class AutoDatabase < CouchExpress::Model
      end
      
      AutoDatabase.database.should == "http://localhost:5984/couch_express" 
    end
  end
end

