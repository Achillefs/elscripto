# frozen_string_literal: true

require 'elscripto'
require 'fileutils'

describe Elscripto::Command do
  before do
    @platform = Elscripto::App.get_platform(RbConfig::CONFIG['host_os'])
    FileUtils.mkdir_p(Elscripto::GLOBAL_CONF_PATHS[@platform])
    @custom_config_path = File.join(Elscripto::GLOBAL_CONF_PATHS[@platform], 'custom.conf')

    File.open(@custom_config_path, 'w') do |f|
      f.write(File.read(File.join('spec', 'files', 'custom.conf')))
    end
  end

  after { File.delete(@custom_config_path) }

  it { expect { Elscripto::Command.new('test_custom_conf_files') }.to_not raise_error }
  it { expect(Elscripto::Command.new('test_custom_conf_files').system_call).to eq('this is a command') }
end
