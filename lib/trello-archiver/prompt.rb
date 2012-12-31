require 'trello'
module TrelloArchiver

  class Prompt
    include Trello
    include Trello::Authorization

    def initialize(config, output = STDOUT)
      @config = config
      @format = set_format
      @output = output
    end

    def set_format
      ENV['TRELLO_FORMAT'] || @config['format'] || 'csv'
    end

    def get_board

      me = Member.find("me")
      boardarray = Array.new
      optionnum = 1
      me.boards.each do |board|
        boardarray << board
        @output << "#{optionnum}: #{board.name} #{board.id}\n"
        optionnum += 1
      end

      @output << "0 - CANCEL\n\n"
      @output << "Which board would you like to backup?\n"
      if @config['board'].nil?
        board_to_archive = gets.to_i - 1
      else
        board_to_archive = @config['board'] - 1
      end

      if board_to_archive == -1
         @output << "Cancelling\n"
         exit 1
      end

      board = Board.find(boardarray[board_to_archive].id)
    end

    def get_filename

      @output << "Would you like to provide a filename? (y/n)\n"

      if @config['filename'] == 'default'
        filename = @board.name.parameterize
      else
        response = gets.downcase.chomp
         if response.to_s =~ /^y/i
           @output << "Enter filename:\n"
           filename = gets.chomp
         else
           filename = @board.name.parameterize
         end
      end


        @output << "Preparing to backup #{@board.name}\n"
        lists = @board.lists
        filename
    end

    def run
      @board = get_board
      @filename = get_filename
      result = {}
      result[:board] = @board
      result[:filename] = @filename
      result[:format] = @format
      result
    end

  end
end
