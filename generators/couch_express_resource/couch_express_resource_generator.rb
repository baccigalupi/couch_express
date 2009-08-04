# Most of this has been ripped from Railties, with some deletions
class CouchExpressResourceGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :verbose
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name
  
  
  def initialize(runtime_args, runtime_options = {}) 
    @verbose = true # need to make this dynamic
    super
    if @name == @name.pluralize && !options[:force_plural]
      logger.warning "Plural version of the model detected, using singularized version.  Override with --force-plural."
      @name = @name.singularize
    end
    
    @controller_name = @name.pluralize 
    
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end 
  end  
    
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions("#{controller_class_name}Controller")
      m.class_collisions(class_name)

      # Controller, specs and models directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory File.join('spec/models', class_path)
      
      # Model class and spec. 
      m.template( 'couch_express_model:couch_express_model.rb',  
        File.join('app/models', class_path, "#{file_name}.rb") 
      )
      m.template( 'rspec_model:model_spec.rb',                   
        File.join('spec/models', class_path, "#{file_name}_spec.rb")
      )  
      m.template( 'couch_express_controller.rb',                 
        File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb" )
      )  
      
      # routes
      m.route_resources controller_file_name
    end
  end               

end  