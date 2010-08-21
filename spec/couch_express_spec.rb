require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/model_fixtures/model')

describe CouchExpress do 
  describe 'config' do
    it 'should look for a default yml file location' do
      CouchExpress.config['development'].class.should == Hash
      CouchExpress.config['development']['database'].should == 'couch_express'
    end
    
    it 'should look in an alternate location' do
      CouchExpress.config(RAILS_ROOT + '/config/alt_couch.yml')['development'].class.should == Hash
      CouchExpress.config(RAILS_ROOT + '/config/alt_couch.yml')['development']['database'].should == 'alt_couch_express'
    end
    
    it '! method should raise a useful error if the file is not found' do  
      path = RAILS_ROOT + '/config/not_here.yml'
      lambda{ CouchExpress.config!( path ) }.should raise_error( 
        ArgumentError, "Looking for CouchDB yaml configuration file at #{path}"
      )
    end
    
    it 'not ! method should return nil when file is not found' do
      CouchExpress.config( RAILS_ROOT + '/config/not_here.yml' ).should == nil
    end
  end
  
  describe 'database_url' do
    it 'should build a url to the database based on the RAILS_ENV' do
      RAILS_ENV = 'development'
      CouchExpress.database_url.should == 'http://localhost:5984/couch_express'
    end
    
    it 'should include protocol if provided' do
      RAILS_ENV = 'staging'
      CouchExpress.database_url.should include 'https'
    end
    
    it 'should include username and password when provided' do
      RAILS_ENV = 'staging'
      CouchExpress.database_url.should include 'kane:password@'
    end
  end
end
