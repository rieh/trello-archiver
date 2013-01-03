#!/usr/bin/env bash

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
PUBLIC_KEY=${TRELLO_PUBKEY}
ACCESS_TOKEN_KEY=${TRELLO_APP_TOKEN}
declare -a HASH_OF_BOARD_HASHES=( BOARDHASH1 BOARDHASH2 ETC ) # must be space delimited

# Beginning of script
# =========
# Do not change below this line

count_number=${#HASH_OF_BOARD_HASHES}

for current_hash in ${HASH_OF_BOARD_HASHES[@]}; do
  echo ${current_hash}
  url="https://api.trello.com/1/boards/${current_hash}?actions=all&actions_limit=1000&cards=all&lists=all&members=all&member_fields=all&checklists=all&fields=all&key=${TRELLO_PUBKEY}&token=${TRELLO_APP_TOKEN}"
  # echo $url
  response=$( curl $url )
  # Check response to see if it's valid
  case $response in
    "invalid id")
      echo "========================================="
      echo "========================================="
      echo "${current_hash} FAILED!"
      echo "========================================="
      echo "========================================="
      ;;
      *)
      echo $response > "$(date +%Y%m%d%H%M%S)_${current_hash}.json"
      ;;
  esac
done
