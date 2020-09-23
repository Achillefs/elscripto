# frozen_string_literal: true

%w[app command version options].each { |r| require "elscripto/#{r}" }

# Parent module for this gem
module Elscripto
  GLOBAL_CONF_PATHS = {
    osx: File.join('/usr', 'local', 'etc', 'elscripto'),
    linux: File.join(ENV['HOME'], '.config', 'elscripto')
  }.freeze

  class LaunchFailedError < RuntimeError # :nodoc:
    def initialize
      super 'Your windows failed to launch. Please check your command definitions'
    end
  end

  class AlreadyInitializedError < RuntimeError # :nodoc:
    def initialize
      super 'The configuration file already exists'
    end
  end

  class NoDefinitionsError < RuntimeError # :nodoc:
    def initialize
      super "No commands or definitions gived.\n
You need to specify at least one of the following:
  --file CONFIG_FILE
  --commands <command 1>;<command 2>...
  --definitions <definition1>;<definition2>..."
    end
  end

  class UnsupportedOSError < RuntimeError # :nodoc:
    def initialize(os)
      super "Sorry, Elscripto does not currently support #{os}"
    end
  end
end
