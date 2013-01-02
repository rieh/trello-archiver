
module TrelloArchiver
  class Archiver
    include Trello
    include Trello::Authorization
    def initialize(options =
            {:board => "",
             :filename => "trello_backup",
             :format => 'xlsx',
             :col_sep => ",",
             :output => STDOUT,
            }
                  )
      @options = options
      @output = options[:output]

      make_archive_folder
      @filename = set_filename
      @lists = @options[:board].lists
      @row_create = ->(sheet, content){ sheet.add_row(content) }
    end

    def create_backup
      create_format_specific_sheet
    end

    private
    def make_archive_folder
      FileUtils.mkdir("archive") unless Dir.exists?("archive")
    end

    def set_filename
      date = DateTime.now.strftime "%Y%m%dT%H%M"
      filename = "#{Dir.pwd}/#{date}_"
      filename += "#{@options[:filename].upcase}.#{@options[:format]}"
      filename
    end
    def create_format_specific_sheet
      case @options[:format]
      when 'xlsx'
        create_xlsx
      when 'csv'
        @options[:col_sep] = ","
        create_csv
      when 'tsv'
        @options[:col_sep] = "\t"
        create_csv
      else
        #
        message = "Trello-archiver can create csv, tsv, and xlsx backups."
        message += " Please choose one of these options and try again.\n"
        @output << message
      end
    end

    def create_csv
      require 'csv'
      header = %w[Name Description Labels Progress Comments]
      content = "[card.name, card.description, result[:labels],"
      content += " list.name, result[:comments].join('')]"

      CSV.open(@filename, "w", :col_sep => @options[:col_sep]) do |sheet|
        sheet.add_row(header)
        @lists.each do |list|
            process_cards_and_append_to_sheet(list, sheet, content)
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
        process_cards_and_append_to_sheet(list, sheet, content)
      end

      # Moving file to where I want it
      require 'fileutils'
      ::FileUtils.mv @doc.path, @filename

      # Cleanup of temp dir
      @doc.cleanup
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
      @output << "\t#{card.name}\n"
      output[:labels] = card_labels_if_existing(card)
      output[:comments] = gather_comments(card)
      output
    end

    def puts_list_and_output_cards(list)
      @output << "#{list.name}\n"
      cards = list.cards
    end

    def process_cards_and_append_to_sheet(list, sheet, content_string)
        puts_list_and_output_cards(list).each do |card|
          result = gather_labels_and_comments(card)
          content = eval(content_string)
          @row_create.call(sheet, content)
        end
    end

  end
end
