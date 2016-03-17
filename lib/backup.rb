class Backup
  BACKUP_DIR = File.expand_path("~/.trollolo/backup")

  attr_reader :board_id
  attr_accessor :directory

  def initialize(board_id, settings)
    @board_id = board_id
    @settings = settings
  end

  def self.list
    Dir.entries(BACKUP_DIR).reject { |d| d =~ /^\./ }
  end

  def backup
    FileUtils.mkdir_p(backup_path)

    trello = TrelloWrapper.new(@settings)

    data = trello.backup(board_id)

    File.open(backup_file, "w") do |f|
      f.write(data)
    end
  end

  def show(options = {})
    out = options[:output] || STDOUT

    board = JSON.parse(File.read(backup_file))

    out.puts board["name"]

    lists = {}
    board["lists"].each do |list|
      lists[list["id"]] = []
    end
    board["cards"].each do |card|
      if lists[card["idList"]]
        lists[card["idList"]].push(card)
      end
    end

    board["lists"].each do |list|
      out.puts "  #{list['name']}"
      lists[list["id"]].each do |card|
        out.puts "    " + card["name"]
        if options["show-descriptions"]
          if !card["desc"].empty?
            out.puts "      Description"
            out.puts "        " + card["desc"]
          end
        end
        card["checklists"].each do |checklist|
          out.puts "      " + checklist["name"]
          checklist["checkItems"].each do |checklist_item|
            out.puts "        " + checklist_item["name"] + " (" +
              checklist_item["state"] + ")"
          end
        end
      end
    end
  end

  private

  def backup_path
    File.join(BACKUP_DIR, board_id)
  end

  def backup_file
    File.join(backup_path, "board.json")
  end
end
