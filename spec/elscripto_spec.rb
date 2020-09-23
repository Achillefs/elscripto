# frozen_string_literal: true

require 'elscripto'

describe Elscripto::App do
  describe 'init!' do
    before do
      @conf_file = File.join('.', '.elscripto')
      Elscripto::App.init!
    end
    after { File.delete(@conf_file) }

    it { File.exist?(@conf_file) }
    it { expect { YAML.safe_load(@conf_file) }.to_not raise_error }
    it { expect(File.read(@conf_file)).to include(Elscripto::App.global_conf_path) }

    it 'does not initialize twice' do
      expect { Elscripto::App.init! }.to raise_error(Elscripto::AlreadyInitializedError)
    end
  end

  subject { Elscripto::App.new(Elscripto::Options.parse('start', %w[-e test -d spork;autotest;rails:server;rails:console])) }

  describe 'with valid options' do
    it { expect(subject.commands.size).to eq(4) }
    it { expect(subject.commands.first.system_call).to eq('spork') }
    it { expect(subject.commands[1].system_call).to eq('autotest') }
    it { expect(subject.commands[2].system_call).to eq('rails s') }
    it { expect(subject.commands.last.system_call).to eq('rails c') }
  end

  describe 'with invalid options' do
    subject do
      conf = Elscripto::Options.parse('start', %w[-f spec/files/nonexistent_command.yml])
      Elscripto::App.new(conf)
    end
    it { expect { subject }.to raise_error(ArgumentError) }
  end

  describe 'with inline command input' do
    subject do
      conf = Elscripto::Options.parse('start', %w[-f spec/files/new_definition.yml])
      Elscripto::App.new(conf)
    end
    it { expect(subject.commands.last.system_call).to eq('rake log:clear') }
    it { expect(subject.commands.last.name).to eq('rails:logs') }
  end

  describe 'platform recongition' do
    it { expect(subject.class.get_platform('darwin10.8.0')).to eq(:osx) }
    it { expect(subject.class.get_platform('x86_64-linux')).to eq(:linux) }
    it { expect(subject.class.get_platform('mswin32')).to eq(:windows) }
  end

  describe 'exec!' do
    let(:platform) { Elscripto::App.get_platform(RbConfig::CONFIG['host_os']) }
    
    before { subject.exec! }
    
    it 'generates correct platform-dependent output' do
      case platform
      when :os
        expect(subject.generated_script).to eq(File.read('spec/files/osascript.txt'))
      when :linux
        if Elscripto::App.is_gnome?
          expect(subject.generated_script).to eq(File.read('spec/files/gnome-script.txt'))
        elsif Elscripto::App.is_kde?
          expect(subject.generated_script).to eq(File.read('spec/files/kde-script.txt'))
        end
      end
    end

    describe 'on an unsupported platform' do
      before { subject.platform = :windows }
      it { expect { subject.exec! }.to raise_error(Elscripto::UnsupportedOSError) }
    end

    describe 'with no definitions' do
      let(:options) { Elscripto::Options.parse('start', []) }
      it { expect { Elscripto::App.new(options) }.to raise_error(Elscripto::NoDefinitionsError) }
    end
  end
end
