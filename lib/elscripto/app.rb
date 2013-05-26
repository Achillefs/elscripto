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
      super "No commands or definitions gived.\n
You need to specify at least one of the following: 
  --file CONFIG_FILE
  --commands CMD1;CMD2...
  --definitions DEF1;DE2..."
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
    attr_accessor :command, :opts, :commands, :platform, :enviroment, :generated_script
    CONFIG_FILE = File.join('.','.elscripto')
    
    def initialize opts
      @opts = opts
      @commands = []
      @command = @opts.command
      @generated_script = ""
      @platform = self.class.get_platform(RbConfig::CONFIG['host_os'])
      first_run?
      @enviroment = @opts.enviroment
      
      if @command == 'start'
        expand_commands!
        add_adhoc_commands!
        raise NoDefinitionsError if @commands.size == 0
      end
    end
    
    def expand_commands!
      # load configuration from file
      if File.exists?(@opts.config_file)
        file_opts = YAML.load_file(@opts.config_file)
        @commands << file_opts['commands'] if file_opts['commands'].class == Array
      end
      # add in definitions
      @commands << @opts.definitions unless @opts.definitions.size == 0
      
      @commands = @commands.flatten.map do |cmd|
        case cmd.class.to_s
        when 'Hash'
          Command.new(cmd['name'], :command => cmd['command'])
        when 'String'
          Command.new(cmd)
        end
      end
    end
    
    def add_adhoc_commands!
      # add in incoming adhoc commands
      i = 1
      @opts.commands.each do |c|
        @commands << Command.new("cmd#{i}",:command => c)
        i+=1
      end
    end
    
    def exec!
      send(@command.to_sym)
    end
    
    def init
      print "\nInitializing elscripto...".yellow
      begin
        self.class.init!
        puts_unless_test " done."
        puts_unless_test "Before continuing, update ./.elscripto with the desired script definitions\n\n".yellow
      rescue Elscripto::AlreadyInitializedError
        puts_unless_test " nah, it's already there!\n".green
      end
    end
    
    def start
      raise Elscripto::NoDefinitionsError.new if self.commands.size == 0
      
      puts_unless_test 'Starting ElScripto Spctacularrr!'.green
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
        def escape_quotes s
          s.gsub('"', '\"')
        end
        @generated_script = %{tell application "Terminal"\n}
        @generated_script<< %{activate\n}
        @generated_script<< commands.map { |cmd| %{tell application "System Events" to keystroke "t" using command down\ndelay 0.5\ndo script "clear && echo \\"-- Running #{escape_quotes cmd.name} Spectacularrr --\\" && #{escape_quotes cmd.system_call}" in front window} }.join("\n")
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
      when :linux
	# Gnome desktops
	# Example script: gnome-terminal --tab -e "tail -f somefile" --tab -e "some_other_command"
        if self.class.is_gnome?
          @generated_script = %{gnome-terminal }
          @generated_script<< commands.map { |cmd| %{--tab --title '#{cmd.name}' -e '#{cmd.system_call}'} }.join(" ")
          if self.enviroment == :production
            raise Elscripto::LaunchFailedError.new unless system(@generated_script)
          else
            @generated_script
          end
	# KDE Desktops, using qdbus
	# CDCMD='cd ~/elscripto'
	# elCommands=('htop' 'tail -f LICENSE.txt' 'tail -f README.md');
	# for i in "${elCommands[@]}"
	# do
	#   session=$(qdbus org.kde.konsole /Konsole  newSession)
	#   qdbus org.kde.konsole /Sessions/${session} sendText "${CDCMD}"
	#   qdbus org.kde.konsole /Sessions/${session} sendText $'\n'
	#   qdbus org.kde.konsole /Sessions/${session} sendText "${i}"
	#   qdbus org.kde.konsole /Sessions/${session} sendText $'\n'
	#   qdbus org.kde.konsole /Sessions/${session} setMonitorActivity true
	# done
	elsif self.class.is_kde?
	  @generated_script = %{CDCMD='cd #{Dir.pwd}'\n}
	  @generated_script<< "elCommands=("
	  @generated_script<< commands.map { |cmd| %{'#{cmd.system_call}'} }.join(" ")
	  @generated_script<< ")\n"
	  @generated_script<< %{for i in "${elCommands[@]}"
do
  session=$(qdbus org.kde.konsole /Konsole  newSession)
  qdbus org.kde.konsole /Sessions/${session} sendText "${CDCMD}"
  qdbus org.kde.konsole /Sessions/${session} sendText $'\n'
  qdbus org.kde.konsole /Sessions/${session} sendText "${i}"
  qdbus org.kde.konsole /Sessions/${session} sendText $'\n'
  qdbus org.kde.konsole /Sessions/${session} setMonitorActivity true
done}
          if self.enviroment == :production
          begin
            tempfile = File.join('/','tmp','elscripto.tmp')
            File.open(tempfile,'w') { |f| f.write(@generated_script) }
            raise Elscripto::LaunchFailedError.new unless system("/bin/bash #{tempfile}")
          ensure
            File.delete(tempfile)
          end
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
          puts_unless_test "Wrote global configuration to #{global_conf_file}".yellow
        end
      end
    end
    
    def puts_unless_test msg
      puts msg unless enviroment == :test
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
      
      def is_gnome?
        system('which gnome-terminal > /dev/null') 
      end
      
      def is_kde?
        system('which konsole > /dev/null') 
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