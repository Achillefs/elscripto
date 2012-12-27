module Elscripto
  class Command
    attr_reader :name, :system_call
    
    BUILTIN_COMMANDS = YAML.load_file(File.join Elscripto::GLOBAL_CONF_PATH, 'elscripto.conf.yml')
    
    def initialize name, options = {}
      raise ArgumentError.new 'Elscripto commands need a name spectacularrr' if blank? name
      @name = name
      @system_call = blank?(options[:command]) ? BUILTIN_COMMANDS[name] : options.delete(:command)
      raise ArgumentError.new 'Elscripto commands need a command spectacularrr' if blank? @system_call
    end
  protected
    def blank? var
      var == '' or var.nil? or var == []
    end
  end
end