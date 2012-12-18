
module TrelloArchiver

  class Authorize
      include Trello
      include Trello::Authorization

      def initialize(config)
        @config = config
      end

      def authorize
        Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

        credential = OAuthCredential.new(@config['public_key'],
                                     @config['private_key'])
        OAuthPolicy.consumer_credential = credential

        OAuthPolicy.token = OAuthCredential.new(
                    @config['access_token_key'], nil )
      end
  end

  class Prompt
    include Trello
    include Trello::Authorization

    def initialize(config)
      @config = config
    end

    def get_board

      me = Member.find("me")
      boardarray = Array.new
      optionnum = 1
      me.boards.each do |board|
        boardarray << board
        puts "#{optionnum}: #{board.name} #{board.id}"
        optionnum += 1
      end

      puts "0 - CANCEL\n\n"
      puts "Which board would you like to backup?"
      if @config['board'].nil?
        board_to_archive = gets.to_i - 1
      else
        board_to_archive = @config['board'] - 1
      end

      if board_to_archive == -1
         puts "Cancelling"
         exit 1
      end

      board = Board.find(boardarray[board_to_archive].id)
    end

    def get_filename

      puts "Would you like to provide a filename? (y/n)"

      if @config['filename'] == 'default'
        filename = @board.name.parameterize
      else
        response = gets.downcase.chomp
         if response.to_s =~ /^y/i
           puts "Enter filename:"
           filename = gets
         else
           filename = @board.name.parameterize
         end
      end


        puts "Preparing to backup #{@board.name}"
        lists = @board.lists
        filename
    end

    def run
      @board = get_board
      @filename = get_filename
      result = {}
      result[:board] = @board
      result[:filename] = @filename
      result
    end
  end

  class Archiver
    include Trello
    include Trello::Authorization
    def initialize(options =
            {:board => "",
             :filename => "trello_backup",
             :format => 'xlsx',
             :col_sep => ","})
      @options = options
      FileUtils.mkdir("archive") unless Dir.exists?("archive")
      date = DateTime.now.strftime "%Y%m%dT%H%M"
      @filename = "#{Dir.pwd}/#{date}_"
      @filename += "#{@options[:filename].upcase}.#{@options[:format]}"

      @lists = @options[:board].lists
      @row_create = ->(sheet, content){ sheet.add_row(content) }
    end

    def create_backup
      case @options[:format]
      when 'csv' && ( @options[:col_sep] == "\t" )
        @options[:format] = 'tsv'
        create_csv
      when 'tsv'
        @options[:col_sep] = "\t"
        create_csv
      when 'csv'
        create_csv
      when 'xlsx'
        create_xlsx
      else
        #
        message = "Trello-archiver can create csv, tsv, and xlsx backups."
        message += " Please choose one of these options and try again."
        puts message
      end
    end

    def card_labels_if_existing(card)
      case card.labels.length
      when 0
        "none"
      else
        card.labels.map { |c| c.name }.join(" ")
      end
    end

    def gather_comments(card)
      card.actions.map do |action|
        if action.type == "commentCard"
          output = "#{Member.find(action.member_creator_id).full_name}"
          output += " [#{ action.date.strftime('%m/%d/%Y') }]"
          output += " : #{action.data['text']} \n\n"
        end
      end
    end

    def gather_labels_and_comments(card)
      output = {}
      puts "\t#{card.name}"
      output[:labels] = card_labels_if_existing(card)
      output[:comments] = gather_comments(card)
      output
    end

    def puts_list_and_output_cards(list)
      puts list.name
      cards = list.cards
    end

    def create_csv
      require 'CSV'
      header = %w[Name Description Labels Progress Comments]
      content = "[card.name, card.description, result[:labels],"
      content += " list.name, result[:comments].join('')]"

      CSV.open(@filename, "w", :col_sep => @options[:col_sep]) do |sheet|
        sheet.add_row(header)
        @lists.each do |list|
            content = "[card.name, card.description, result[:labels], list.name, result[:comments].join('')]"
            main_process(list, sheet, content)
        end
      end
    end

    def create_xlsx
      require 'xlsx_writer'
      header = %w[Name Description Labels Comments]
      content = "[card.name, card.description, result[:labels], result[:comments].join('')]"

      @doc = XlsxWriter.new

      @lists.each do |list|
        sheet = @doc.add_sheet(list.name.gsub(/\W+/, '_'))
        sheet.add_row( header )
        content = "[card.name, card.description, result[:labels], result[:comments].join('')]"
        main_process(list, sheet, content)
      end

      # Moving file to where I want it
      require 'fileutils'
      ::FileUtils.mv @doc.path, @filename

      # Cleanup of temp dir
      @doc.cleanup
    end

    def main_process(list, sheet, content_string)
        puts_list_and_output_cards(list).each do |card|
          result = gather_labels_and_comments(card)
          content = eval(content_string)
          @row_create.call(sheet, content)
        end
    end

  end
end
