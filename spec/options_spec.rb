# frozen_string_literal: true

require 'elscripto'

describe Elscripto::Options do
  let(:cmd) { 'start' }
  subject { Elscripto::Options }
  describe 'defaults' do
    subject { Elscripto::Options.parse(cmd, []) }
    it { expect(subject.verbose).to eq(false) }
    it { expect(subject.path).to eq(FileUtils.pwd) }
    it { expect(subject.command).to eq(cmd) }
    it { expect(subject.config_file).to eq('./.elscripto') }
  end

  describe 'enviroment' do
    it { expect(subject.parse(cmd, %w[-e development]).enviroment).to eq(:development) }
    it { expect(subject.parse(cmd, %w[--enviroment=development]).enviroment).to eq(:development) }
  end

  describe 'invalid command' do
    it { expect { subject.parse('random', []) }.to raise_error(Elscripto::InvalidCommandError) }
  end

  describe 'path options' do
    let(:path) { '/test/path' }

    describe '--path PATH' do
      it { expect(subject.parse(cmd, %W[-p #{path}]).path).to eq(path) }
      it { expect(subject.parse(cmd, %W[--path #{path}]).path).to eq(path) }
    end

    describe '--file PATH' do
      it { expect(subject.parse(cmd, %W[-f #{path}]).config_file).to eq(path) }
      it { expect(subject.parse(cmd, %W[--file #{path}]).config_file).to eq(path) }
    end
  end

  describe 'array options' do |_variable|
    let(:commands) { 'cmd1;cmd2; cmd3  ;cmd4' }
    let(:parsed) { %w[cmd1 cmd2 cmd3 cmd4] }

    describe '--commands CMDS' do
      it { expect(subject.parse(cmd, %W[-c #{commands}]).commands).to eq(parsed) }
      it { expect(subject.parse(cmd, %W[--commands #{commands}]).commands).to eq(parsed) }
    end

    describe '--definitions DEFS' do
      it { expect(subject.parse(cmd, %W[-d #{commands}]).definitions).to eq(parsed) }
      it { expect(subject.parse(cmd, %W[--definitions #{commands}]).definitions).to eq(parsed) }
    end
  end
end
