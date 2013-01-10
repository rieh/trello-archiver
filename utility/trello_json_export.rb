#!/usr/bin/env ruby
require 'open-uri'
require 'json'
# require 'pry'
require 'yaml'

# Script to export json data from Trello
# Written by ZPH <zander@civet.ws>
# Credit for API call belongs to http://www.shesek.info/general/automatically-backup-trello-lists-cards-and-other-data
# 
# Caveats:
# -API limits the number certain parameters returned.
#   -JSON output may be truncated for large boards; further research needed.

# Variables to set as Environmental Variables or directly in script
# PUBLIC_KEY='32CHARACTERPUBLICKEY'
# ACCESS_TOKEN_KEY='65CHARACTERAPPLICATIONTOKEN'
# Board hashes can be found in URL of board or by using script in Trello-Archiver

# Use config.yml for easy storage of variables
# This block loads each of the variables
# If the config.yml is not used, hard code values
CONFIG = YAML.load_file('config.yml')
board_hash = CONFIG['board_hash']
key = CONFIG['public_key']
application_token = CONFIG['access_token_key']
username = CONFIG['username']

# Gather board_hashes
url_slug = "https://api.trello.com/1"
boards = "#{url_slug}/members/#{username}/boards?&key=#{key}&token=#{application_token}"

board_json = JSON.parse(open(boards).read)
board_hashes = board_json.map { |d| d['id'].chomp }

# Gather JSON dump for each board
board_hashes.each do |board_hash|
  puts board_hash
  url = "https://api.trello.com/1/boards/#{board_hash}?actions=all&actions_limit=1000&cards=all&lists=all&members=all&member_fields=all&checklists=all&fields=all&key=#{key}&token=#{application_token}"
  response = open(url).read
  output_filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{board_hash}.json"

  case response
  when "invalid id"
      puts "========================================="
      puts "========================================="
      puts "#{board_hash} FAILED!"
      puts "========================================="
      puts "========================================="
      ;;
  else
      File.write(output_filename, response)
  end

end

