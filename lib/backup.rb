class Backup

  attr_accessor :directory

  def initialize settings
    @settings = settings
    @directory = File.expand_path("~/.trollolo/backup")
  end

  def backup(board_id)
    backup_path = File.join(@directory, board_id)
    FileUtils.mkdir_p(backup_path)

    trello = Trello.new(board_id: board_id,
      developer_public_key: @settings.developer_public_key,
      member_token: @settings.member_token,
      verbose: @settings.verbose)

    data = trello.full_board

    File.open(File.join(backup_path,"board.json"), "w") do |f|
      f.write(JSON.pretty_generate(data))
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
      lists[card["idList"]].push(card)
    end

    board["lists"].each do |list|
      out.puts "  #{list['name']}"
      lists[list["id"]].each do |card|
        out.puts "    " + card["name"]
      end
    end
  end

end
