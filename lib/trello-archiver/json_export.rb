require 'open-uri'
require 'json'
require 'pry'
require 'yaml'

CONFIG = YAML.load_file('config.yml')
board_hash = CONFIG['board_hash']
key = CONFIG['public_key']
application_token = CONFIG['access_token_key']
url = "https://api.trello.com/1/boards/#{board_hash}?cards=all&card_attachments=true&card_attachment_fields=all&members=all&membersInvited=all&checklists=all&lists=all&key=#{key}&token=#{application_token}"

a = open(url).read
puts a.length
