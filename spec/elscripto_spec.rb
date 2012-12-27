require 'elscripto'
describe Elscripto::App do
  describe 'init!' do
    before { 
      @conf_file = File.join('.','.elscripto')
      Elscripto::App.init!
    }
    after { File.delete(@conf_file) }
    
    it { File.exists?(@conf_file) }
    it { expect { YAML.load(@conf_file) }.to_not raise_error }
    it { File.read(@conf_file).include?(Elscripto::App.global_conf_path).should eq(true) }
    
    it 'should not initialize twice' do
      expect { Elscripto::App.init! }.to raise_error(Elscripto::AlreadyInitializedError)
    end
  end
  
  subject { Elscripto::App.new 'spec/files/sample_options.yml', :enviroment => :development }
  
  describe 'with valid options' do
    it { subject.commands.size.should eq(4) }
    it { subject.commands.first.system_call.should eq('spork') }
    it { subject.commands[1].system_call.should eq('autotest') }
    it { subject.commands[2].system_call.should eq('rails s') }
    it { subject.commands.last.system_call.should eq('rails c') }
  end
  
  describe 'with invalid options' do
    subject { Elscripto::App.new 'spec/files/nonexistent_command.yml' }
    it { expect { subject }.to raise_error(ArgumentError) }
  end
  
  describe 'with inline command input' do
    subject { Elscripto::App.new 'spec/files/new_definition.yml' }
    it { subject.commands.last.system_call.should eq('rake log:clear') }
    it { subject.commands.last.name.should eq('rails:logs') }
  end
  
  describe 'platform recongition' do
    it { subject.class.get_platform("darwin10.8.0").should eq(:osx) }
    it { subject.class.get_platform("x86_64-linux").should eq(:linux) }
    it { subject.class.get_platform("mswin32").should eq(:windows) }
  end
  
  describe 'exec!' do
    describe 'on osx' do
      before { subject.exec! }
      it { subject.generated_script.should eq(File.read('spec/files/osascript.txt')) }
    end
    
    describe 'on an unsupported platform' do
      before { subject.platform = :windows }
      it { expect { subject.exec! }.to raise_error(Elscripto::UnsupportedOSException) }
    end
    
    describe "with no definitions" do
      subject { Elscripto::App.new 'spec/files/empty.yml' }
      it { expect { subject }.to raise_error(Elscripto::NoDefinitionsError) }
    end
  end
end