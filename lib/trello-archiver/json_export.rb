require 'open-uri'
require 'json'
# require 'pry'
require 'yaml'

CONFIG = YAML.load_file('config.yml')
board_hash = CONFIG['board_hash']
key = CONFIG['public_key']
application_token = CONFIG['access_token_key']

url_slug = "https://api.trello.com/1"
url = "#{url_slug}/boards/#{board_hash}?actions=all&actions_limit=1000&cards=all&lists=all&members=all&member_fields=all&checklists=all&fields=all&key=#{key}&token=#{application_token}"

boards = "#{url_slug}/members/zanderhill/boards?&key=#{key}&token=#{application_token}"

a = JSON.parse(open(url).read)
board_json = JSON.parse(open(boards).read)
board_hashes = board_json.map { |d| d['id'].chomp }
print board_hashes.join(" ")
# binding.pry
# puts a.length
# File.write("auto_output.json", a)
