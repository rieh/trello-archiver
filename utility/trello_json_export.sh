#!/usr/bin/env bash

# Script to export json data from Trello
# Written by ZPH <zander@civet.ws>
# Credit for API call belongs to http://www.shesek.info/general/automatically-backup-trello-lists-cards-and-other-data
# 
# Usage:
  # Uses ruby for handling JSON using STDLIB.
  # Depends on valid keys and app token in config.yml
  # From base directory of git repo.
  # TO EXECUTE
  ############
  # ruby lib/trello-archiver/json_export.rb | xargs bash utility/trello_json_export.sh
# Caveats:
# -API limits the number certain parameters returned.
#   -JSON output may be truncated for large boards; further research needed.

# Variables are egrepped by default from config.yml
# Variables to set as Environmental Variables or directly in script
# PUBLIC_KEY='32CHARACTERPUBLICKEY'
# ACCESS_TOKEN_KEY='65CHARACTERAPPLICATIONTOKEN'
# Board hashes can be found in URL of board or by using script in Trello-Archiver
#### Example of setting these via Env Variables
# PUBLIC_KEY=${TRELLO_PUBKEY}
# ACCESS_TOKEN_KEY=${TRELLO_APP_TOKEN}
#### Default where values are egrepped from config.yml
PUBLIC_KEY=$(egrep -oi ":\W?(\<[[:alnum:]]{32}\>)$" config.yml | cut -f2 -d ' ')
ACCESS_TOKEN_KEY=$(egrep -oi "access_token_key:\W?(\<[[:alnum:]]{64,}\>)$" config.yml | cut -f2 -d ' ')

# Beginning of script
# =========
# Start loop to act on args until args are all completed
while [ -n "$1" ]
  do
    current_hash=$1
    echo "Board Hash: $current_hash"
    url="https://api.trello.com/1/boards/$(echo $current_hash)?actions=all&actions_limit=1000&cards=all&lists=all&members=all&member_fields=all&checklists=all&fields=all&key=${PUBLIC_KEY}&token=${ACCESS_TOKEN_KEY}"
    echo "URL : $url"
    response=$( curl $url )
    # Check response to see if it's valid
    case $response in
      "invalid id")
        echo "========================================="
        echo "========================================="
        echo "$current_hash FAILED!"
        echo "========================================="
        echo "========================================="
        ;;
      "unauthorized permission request")
        echo "========================================="
        echo "========================================="
        echo "$current_hash FAILED!"
        echo "========================================="
        echo "========================================="
        ;;
        *)
        echo $response > "$(date +%Y%m%d%H%M%S)_$current_hash.json"
        ;;
    esac
    shift
done
