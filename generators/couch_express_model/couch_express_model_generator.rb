class SpringModelGenerator < Rails::Generator::NamedBase
  attr_accessor :verbose 


  def manifest
    record do |m|
      @verbose = true
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Model, spec, and fixture directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('spec/models', class_path)
      
      # Model class, spec and fixtures.
      m.template 'couch_express_model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
      m.template 'rspec_model:model_spec.rb',  File.join('spec/models', class_path, "#{file_name}_spec.rb")
    end  
  end # manifest  

end # SpringModelGenerator
  