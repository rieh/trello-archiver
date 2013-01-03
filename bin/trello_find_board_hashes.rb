# encoding: utf-8
#!/usr/bin/env ruby

# $LOAD_PATH.unshift 'lib'
require 'trello'
require 'yaml'
require_relative '../lib/trello-archiver.rb'

include Trello
include Trello::Authorization

CONFIG = YAML::load(File.open("config.yml")) unless defined? CONFIG

TrelloArchiver::Authorize.new(CONFIG).authorize

me = Member.find("me")
me.boards.each { |d| puts "#{d.id} #{d.name}" }
