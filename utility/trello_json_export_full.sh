#!/usr/bin/env bash

ruby lib/trello-archiver/json_export.rb | xargs bash utility/trello_json_export.sh
