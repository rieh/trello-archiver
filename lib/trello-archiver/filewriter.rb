require 'xlsx_writer'

class TrelloArchiver

  def initialize(options = {:board => "", :filename => "trello_backup", :format => 'xlsx'})
    @options = options
    FileUtils.mkdir("archive") unless Dir.exists?("archive")
  end

  def createspreadsheet()
    case @options[:format]
    when 'csv'
      create_csv
    when 'xlsx'
      create_xlsx
    else
      create_xlsx
    end
    
  end

  def create_csv()
    require 'CSV'
    # Filename= filename or default of boardname
    # 
    # Board object has been passed into the method
    lists = @options[:board].lists
    filename = "archive/#{DateTime.now.strftime "%Y%m%dT%H%M"}_#{@options[:filename]}.csv"

    CSV.open(filename, "w") do |csv|
      # Sheets have to be restructured as a field
      #
      # Add header row
      csv << %w[Name Description Labels Progress Comments]

      lists.each do |list|
        puts list.name
        cards = list.cards
        
        cards.each do |card|
          # Add title row
          puts card.name
          # gather and join the labels if they exist
          labels = case card.labels.length
          when 0
            "none"
          else
            card.labels.map { |c| c.name }.join(" ")
          end

          # Gather comments
          comments = card.actions.map do |action|
            if action.type == "commentCard"
              # require 'pry'; binding.pry
              "#{Member.find(action.member_creator_id).full_name} [#{ action.date.strftime('%m/%d/%Y') }] : #{action.data['text']} \n\n"
            end
          end

          csv << [card.name, card.description, labels, list.name, comments.join('')]
        end
      end
    end
  end

  def create_xlsx()
    # Filename= filename or default of boardname
    # 
    # Board object has been passed into the method
    lists = @options[:board].lists
    filename = "archive/#{DateTime.now.strftime "%Y%m%dT%H%M"}_#{@options[:filename]}.xlsx"

    @doc = XlsxWriter.new

    lists.each do |list|
      sheet = @doc.add_sheet(list.name.gsub(/\W+/, '_'))
      puts list.name
      cards = list.cards
      #
      # Add header row
      sheet.add_row( %w[Name Description Labels Comments])
      
      cards.each do |card|
        # Add title row
        puts card.name
        # sheet.add_row([
        #   "Title: #{card.name}",
        #   "Desc: #{card.description}",
        #   "Labels: #{card.labels.length}"
        # ])
        
        # gather and join the labels if they exist
        labels = case card.labels.length
        when 0
          "none"
        else
          card.labels.map { |c| c.name }.join(" ")
        end

        # Gather comments
        comments = card.actions.map do |action|
          if action.type == "commentCard"
            # require 'pry'; binding.pry
            "#{Member.find(action.member_creator_id).full_name} [#{ action.date.strftime('%m/%d/%Y') }] : #{action.data['text']} \n\n"
          end
        end

        sheet.add_row([card.name, card.description, labels, comments.join('')])
      end
    end

    # Moving file to where I want it
    require 'fileutils'
    ::FileUtils.mv @doc.path, File.join(File.dirname(__FILE__), "..", "..", filename)

    # Cleanup of temp dir
    @doc.cleanup
  end

end
