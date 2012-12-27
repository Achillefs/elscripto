module Elscripto
  class Command
    attr_reader :name, :system_call
    
    def initialize name, options = {}
      raise ArgumentError.new 'Elscripto commands need a name spectacularrr' if blank? name
      @name = name
      @system_call = blank?(options[:command]) ? builtin_commands[name] : options.delete(:command)
      raise ArgumentError.new 'Elscripto commands need a command spectacularrr' if blank? @system_call
    end
  protected
    def builtin_commands
      YAML.load_file(File.join Elscripto::App.global_conf_path, 'elscripto.conf.yml')
    end
    
    def blank? var
      var == '' or var.nil? or var == []
    end
  end
end