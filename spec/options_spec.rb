require 'elscripto'
describe Elscripto::Options do
  let(:cmd) { 'start' }
  subject { Elscripto::Options }
  describe 'defaults' do
    subject { Elscripto::Options.parse(cmd,[]) }
    its(:verbose) { should eq(false) }
    its(:path) { should eq(FileUtils.pwd) }
    its(:command) { should eq(cmd) }
    its(:config_file) { should eq('./.elscripto') }
  end
  
  describe 'enviroment' do
    it { subject.parse(cmd,%W{-e development}).enviroment.should eq(:development) }
    it { subject.parse(cmd,%W{--enviroment=development}).enviroment.should eq(:development) }
  end
  
  describe 'invalid command' do
    it {expect { subject.parse('random',[])}.to raise_error(Elscripto::InvalidCommandError)  }
  end
  
  describe 'path options' do
    let(:path) { '/test/path' }
    
    describe '--path PATH' do
      it { subject.parse(cmd,%W{-p #{path}}).path.should eq(path) }
      it { subject.parse(cmd,%W{--path #{path}}).path.should eq(path) }
    end
    
    describe '--file PATH' do
      it { subject.parse(cmd,%W{-f #{path}}).config_file.should eq(path) }
      it { subject.parse(cmd,%W{--file #{path}}).config_file.should eq(path) }
    end
  end
  
  describe 'array options' do |variable|
    let(:commands) { 'cmd1;cmd2; cmd3  ;cmd4' }
    let(:parsed) { %W{cmd1 cmd2 cmd3 cmd4}}
    
    describe '--commands CMDS' do
      it { subject.parse(cmd,%W{-c #{commands}}).commands.should eq(parsed) }
      it { subject.parse(cmd,%W{--commands #{commands}}).commands.should eq(parsed) }
    end

    describe '--definitions DEFS' do
      it { subject.parse(cmd,%W{-d #{commands}}).definitions.should eq(parsed) }
      it { subject.parse(cmd,%W{--definitions #{commands}}).definitions.should eq(parsed) }
    end
  end
end