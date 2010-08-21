COUCH_EXPRESS = File.dirname(__FILE__) 

module CouchExpress
  def self.config!( path = default_config_path )
    begin 
      content = File.read( path )
    rescue
      raise ArgumentError, "Looking for CouchDB yaml configuration file at #{path}"
    end 
    YAML.load( content )
  end
  
  def self.config( path = default_config_path ) 
    config!(path) rescue nil
  end
  
  def self.default_config_path
    (defined?(::RAILS_ROOT) ? ::RAILS_ROOT : File.dirname(__FILE__) + '/../..') + '/config/couch.yml'
  end
  
  def self.database_url
    env = defined?(::RAILS_ENV) ? ::RAILS_ENV : 'development'
    if config_opts = config
      opts = config[env]
      credentials = opts['username'] ? "#{opts['username']}:#{opts['password']}@" : ''
      "#{opts['protocol'] || 'http'}://#{credentials}#{opts['domain']}/#{opts['database']}"
    end
  end
end

# load in CouchRest
require COUCH_EXPRESS + '/couchrest/lib/couchrest'

# load in this lib!
require COUCH_EXPRESS + '/couch_express/couch_express_model'
require COUCH_EXPRESS + '/couch_express/couch_express_validated_model' 