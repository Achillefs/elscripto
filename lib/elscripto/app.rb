require 'yaml'
require 'rbconfig'
require 'nutrun-string'

module Elscripto # :nodoc:
  GLOBAL_CONF_PATHS = {
    :osx => File.join('/usr','local','etc','elscripto'),
    :linux => File.join(ENV['HOME'],'.config','elscripto')
  }
  
  class LaunchFailedError < Exception # :nodoc:
    def initialize
      super "Your windows have failed to launch. Please check your command definitions"
    end
  end
  
  class AlreadyInitializedError < Exception # :nodoc:
    def initialize
      super "The configuration file already exists"
    end
  end
  
  class NoDefinitionsError < Exception # :nodoc:
    def initialize
      super "No definitions in your configuration file. What's the deal, guy?"
    end
  end
  
  class UnsupportedOSError < Exception # :nodoc:
    def initialize(os)
      super "Sorry, Elscripto does not currently support #{os}"
    end
  end
  
  # This is the application class used by the elscripto binary
  # Initialize it by passing a config file to it. 
  # Default file path is <current_dir>/.elscripto
  class App
    attr_accessor :commands, :platform, :enviroment, :generated_script
    CONFIG_FILE = File.join('.','.elscripto')
    
    def initialize opts_file, opts = {}
      @commands = []
      @generated_script = ""
      @platform = self.class.get_platform(RbConfig::CONFIG['host_os'])
      first_run?
      @enviroment = opts.delete(:enviroment) || :production
      config_file = opts_file ? opts_file : CONFIG_FILE
      raise ArgumentError.new "Elscripto needs a config file spectacularrr" unless File.exists?(config_file)
      opts = YAML.load_file(config_file)
      raise Elscripto::NoDefinitionsError.new unless opts['commands'].class == Array
      opts['commands'].each do |cmd|
        case cmd.class.to_s
        when 'Hash'
          @commands << Command.new(cmd['name'], :command => cmd['command'])
        when 'String'
          @commands << Command.new(cmd)
        end
      end
    end
    
    def exec!
      raise Elscripto::NoDefinitionsError.new if self.commands.size == 0
      case self.platform
      # tell application "Terminal"
      # 	activate
      # 	delay 1
      # 	do script "clear && echo \"--STARTING SPORK SERVER--\" && cd Sites/tabbo/ && spork" in front window
      # 	tell application "System Events" to keystroke "t" using command down
      # 	do script "clear && echo \"--STARTING RAILS SERVER--\" && cd Sites/tabbo/ && rails c" in front window
      # 	tell application "System Events" to keystroke "t" using command down
      # 	do script "clear && echo \"--STARTING AUTOTEST--\" && cd Sites/tabbo/ && autotest" in front window
      # end tell
      when :osx
        @generated_script = %{tell application "Terminal"\n}
        @generated_script<< %{activate\n}
        @generated_script<< commands.map { |cmd| %{tell application "System Events" to keystroke "t" using command down\ndelay 0.5\ndo script "clear && echo \\"-- Running #{cmd.name} Spectacularrr --\\" && #{cmd.system_call}" in front window} }.join("\n")
        @generated_script<< "\nend tell"
        if self.enviroment == :production
          begin
            tempfile = File.join(ENV['TMPDIR'],'elscripto.tmp')
            File.open(tempfile,'w') { |f| f.write(@generated_script) }
            raise Elscripto::LaunchFailedError.new unless system("osascript #{tempfile}")
          ensure
            File.delete(tempfile)
          end
        else
          @generated_script
        end
      # Currently only works on Gnome desktop, although implementing this for other terminal apps is trivial
      # Example script: gnome-terminal --tab -e "tail -f somefile" --tab -e "some_other_command"
      when :linux
        if system('which gnome-terminal') 
          @generated_script = %{gnome-terminal }
          @generated_script<< commands.map { |cmd| %{--tab --title '#{cmd.name}' -e '#{cmd.system_call}'} }.join(" ")
          if self.enviroment == :production
            raise Elscripto::LaunchFailedError.new unless system(@generated_script)
          else
            @generated_script
          end
        else
          Elscripto::UnsupportedOSError.new('your flavour of linux')
        end
      else
        raise Elscripto::UnsupportedOSError.new(self.platform)
      end
    end
    
    def first_run?
      global_conf_file = File.join(GLOBAL_CONF_PATHS[platform],'_default.conf')
      
      case platform
      when :osx,:linux
        unless File.exists?(global_conf_file)
          require 'fileutils'
          FileUtils.mkdir_p(GLOBAL_CONF_PATHS[platform])
          File.open(global_conf_file,'w') do |f|
            f.write(File.read(File.join(File.dirname(__FILE__),'..','..','config','elscripto.conf.yml')))
          end
          puts "Wrote global configuration to #{global_conf_file}".yellow
        end
      end
    end
    
    class << self
      def init!
        if File.exists?(CONFIG_FILE)
          raise Elscripto::AlreadyInitializedError.new
        else
          File.open(CONFIG_FILE,'w') do |f|
            f.write File.read(File.join(File.dirname(__FILE__),'..','..','config','elscripto.init.yml')).gsub('{{GLOBAL_CONF_PATH}}',self.global_conf_path)
          end
        end
      end

      def global_conf_path
        Elscripto::GLOBAL_CONF_PATHS[self.get_platform(RbConfig::CONFIG['host_os'])]
      end

      # Determine the platform we're running on
      def get_platform(host_os)
        return :osx if host_os =~ /darwin/
        return :linux if host_os =~ /linux/
        return :windows if host_os =~ /mingw32|mswin32/
        return :unknown
      end
    end
  end
end