# frozen_string_literal: true

require 'optparse'
require 'ostruct'
require 'fileutils'

module Elscripto
  class InvalidCommandError < StandardError
  end

  class Options
    VALID_COMMANDS = %w[init start].freeze

    # A customized OptionsParser
    def self.parse(command, args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new
      options.verbose = false
      options.path = FileUtils.pwd
      options.command = command
      options.config_file = './.elscripto'
      options.commands = options.definitions = []
      options.enviroment = :production
      opts = OptionParser.new do |opts|
        opts.program_name = 'elscripto'
        opts.banner = "Usage: #{opts.program_name} init|start [options]".green
        opts.separator ''
        opts.separator 'Options:'.green

        opts.on('-p', '--path PATH', "Set elscripto's working directory") do |path|
          options.path = path
        end

        opts.on('-c', '--commands CMD1;CMD2;CMD3...', 'Pass a list of comma-separated commands') do |cmds|
          options.commands = cmds.split(';').map(&:strip)
        end

        opts.on('-d', '--definitions DEF1;DEF2;DEF3...', 'Pass a list of comma-separated command definitions') do |defs|
          options.definitions = defs.split(';').map(&:strip)
        end

        opts.on('-f', '--file CONFIG FILE PATH', 'Pass a path to a config file') do |conf_file|
          options.config_file = conf_file
        end

        opts.on('-e', '--enviroment [production|development]', 'Define runtime enviroment') do |env|
          options.enviroment = env.to_sym
        end
      end

      opts.separator ''
      opts.separator 'Common options:'.green

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end

      opts.on_tail('-v', '--version', 'Show version') do
        puts "#{opts.program_name} #{Elscripto::VERSION}\n(c) 2013, Achillefs Charmpilas".green
        exit
      end

      opts.parse!(args)
      unless VALID_COMMANDS.include?(options.command)
        raise Elscripto::InvalidCommandError, "Please specify a valid command [#{VALID_COMMANDS.join('|')}]"
      end

      options
    end
  end
end
