require_relative '../spec_helper'

describe 'bin/trello_backup.rb' do
  describe "should properly set file format based on ENV variable" do
    %w[xlsx csv tsv].each do |test_format|
      it "should set format to #{test_format}" do
        require 'yaml'
        require 'trello'
        CONFIG = YAML::load(File.expand_path "config.yml") unless defined? CONFIG

        TrelloArchiver::Authorize.new(CONFIG).authorize
        ENV['TRELLO_FORMAT'] = test_format

        input = TrelloArchiver::Prompt.new(CONFIG).run
        format = TrelloArchiver::Prompt.set_format
        input[:format].should eq(test_format)
      end
    end
  end
  describe "should properly set file format based on config.yml " do
    %w[xlsx csv tsv].each do |test_format|
      it "should set format to #{test_format}" do
        require 'yaml'

        CONFIG = YAML::load(File.open("config.yml")) unless defined? CONFIG

        TrelloArchiver::Authorize.new(CONFIG).authorize
        CONFIG['format'] = test_format
        input = TrelloArchiver::Prompt.new(CONFIG).run
        puts input
        # format = TrelloArchiver::Prompt.set_format
        input[:format].should eq(test_format)
      end
    end
  end
end
