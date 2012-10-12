require 'xlsx_writer'

def createspreadsheet(board, filenamestub="productbacklogbackup", includecomments=true)
  # Filenamestub = filename or default of boardname
  # 
  # Board object has been passed into the method
  lists = board.lists
  FileUtils.mkdir("archive") unless Dir.exists?("archive")
  filename = "archive/#{DateTime.now.strftime "%Y%m%dT%H%M"}_#{filenamestub}.xlsx"

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

  # SimpleXlsx::Serializer.new(filename) do |doc|
  #   lists.each do |list|
  #     # logging puts of list name
  #     puts list.name
  #     # Gather set of all cards in each list
  #     cards = list.cards
  #     # Add workbook based on list name
  #     doc.add_sheet(list.name) do |sheet|
  #       # Add header row
  #       sheet.add_row(%w{Name Description Labels Comments})
  #       # For each card, dump data in new row
  #       cards.each do |card|
  #         puts "Title: #{card.name} Desc: #{card.description} List: #{card.list.name} Labels:#{card.labels.length}"
          
  #         if card.labels.length==0 then labellist = "none" else labellist = "" end
  #         card.labels.each do |label|
  #           labellist += " " + label.name
  #         end

  #         if includecomments
  #           # Gather all items from card's timeline, ie all the comments along the way
  #           actions = card.actions
  #           commentslist = ""
  #           actions.each do |action|
  #             if action.type=="commentCard"
  #               commentslist += "#{Member.find(action.member_creator_id).full_name} says: #{action.data['text']} \n\n"
  #             end
  #           end
  #         end
          
  #         # After each of the content items has been created,
  #         # dump that data into a new row
  #         sheet.add_row([card.name, card.description, labellist, commentslist])
  #       end
  #     end
  #   end
  # end
# end
