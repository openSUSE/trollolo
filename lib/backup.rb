require 'fileutils'

class Backup

  attr_accessor :directory

  def initialize(settings)
    @settings = settings
    @directory = File.expand_path('~/.trollolo/backup')
  end

  def backup(board_id)
    backup_path = File.join(@directory, board_id, Time.now.to_i.to_s)

    FileUtils.mkdir_p(backup_path)

    trello = TrelloWrapper.new(@settings)
    data = trello.backup(board_id)

    File.open(File.join(backup_path, 'board.json'), 'w') do |f|
      f.write(data)
    end
  end

  def list
    backups = {}
    Dir.foreach(@directory) do |sub_dir|
      unless sub_dir =~ /^\./
        sub_dir_path = File.join(@directory, sub_dir)
        backups[sub_dir] = Dir.entries(sub_dir_path).reject { |d| d =~ /^\./ }
      end
    end

    backups
  end

  def show_diff(board_id, version, optional_version)
    if optional_version.nil?
      trello = TrelloWrapper.new(@settings)
      board_online = trello.retrieve_board_data(board_id)

      backup_path = File.join(@directory, board_id, version, 'board.json')
      board_backup = JSON.parse(File.read(backup_path))

      JsonDiff.diff(board_backup, board_online)
    else
      backup_path = File.join(@directory, board_id, version, 'board.json')
      board_backup = JSON.parse(File.read(backup_path))

      second_backup_path = File.join(@directory, board_id, optional_version, 'board.json')
      board_second_backup = JSON.parse(File.read(second_backup_path))

      JsonDiff.diff(board_backup, board_second_backup)
    end
  end

  def show(board_id, version, options = {})
    out = options[:output] || STDOUT

    backup_path = File.join(@directory, board_id, version)

    board = JSON.parse(File.read(File.join(backup_path, 'board.json')))

    out.puts board['name']

    lists = {}
    board['lists'].each do |list|
      lists[list['id']] = []
    end
    board['cards'].each do |card|
      lists[card['idList']].push(card) if lists[card['idList']]
    end

    board['lists'].each do |list|
      out.puts "  #{list['name']}"
      lists[list['id']].each do |card|
        out.puts '    ' + card['name']
        if options['show-descriptions']
          unless card['desc'].empty?
            out.puts '      Description'
            out.puts '        ' + card['desc']
          end
        end
        card['checklists'].each do |checklist|
          out.puts '      ' + checklist['name']
          checklist['checkItems'].each do |checklist_item|
            out.puts '        ' + checklist_item['name'] + ' (' +
              checklist_item['state'] + ')'
          end
        end
      end
    end
  end

end
