RAILS_ROOT = File.dirname(__FILE__) 
# get CouchRest code
Dir["#{File.dirname(__FILE__)}/../lib/couchrest/lib/couchrest"].each {|f| require f}
# get CouchExpress code
Dir["#{File.dirname(__FILE__)}/../lib/couch_express"].each {|f| require f} 

unless defined?( DB )
  MODEL_FIXTURES = File.join(File.dirname(__FILE__), '/fixtures')
  COUCHHOST = "http://127.0.0.1:5984"
  TESTDB    = 'couch_express_test' 
  TEST_SERVER    = CouchRest.new
  TEST_SERVER.default_database = TESTDB
  DB = TEST_SERVER.database(TESTDB) 
end   

Spec::Runner.configure do |config|
end
