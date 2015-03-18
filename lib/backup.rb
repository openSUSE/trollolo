class Backup

  attr_accessor :directory

  def initialize settings
    @settings = settings
    @directory = File.expand_path("~/.trollolo/backup")
  end

  def backup(board_id)
    backup_path = File.join(@directory, board_id)
    FileUtils.mkdir_p(backup_path)

    trello = TrelloWrapper.new(@settings)

    data = trello.backup(board_id)

    File.open(File.join(backup_path, "board.json"), "w") do |f|
      f.write(data)
    end
  end

  def list
    Dir.entries(@directory).reject { |d| d =~ /^\./ }
  end

  def show(board_id, options = {})
    out = options[:output] || STDOUT

    backup_path = File.join(@directory, board_id)

    board = JSON.parse(File.read(File.join(backup_path, "board.json")))

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

end
