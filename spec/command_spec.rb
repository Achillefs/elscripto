require 'elscripto'
require 'fileutils'

describe Elscripto::Command do
  before { 
    @platform = Elscripto::App.get_platform(RbConfig::CONFIG['host_os'])
    FileUtils.mkdir_p(Elscripto::GLOBAL_CONF_PATHS[@platform])
    @custom_config_path = File.join(Elscripto::GLOBAL_CONF_PATHS[@platform],'custom.conf')
    
    File.open(@custom_config_path,'w') do |f| 
      f.write(File.read(File.join('spec','files','custom.conf')))
    end
  }
  
  after { File.delete(@custom_config_path) }
  
  it { expect { Elscripto::Command.new('test_custom_conf_files') }.to_not raise_error }
  it { Elscripto::Command.new('test_custom_conf_files').system_call.should eq('this is a command') }
end