class CliBackup < Thor
  include CliSettings

  desc 'create', 'Create backup of board'
  option 'board-id', desc: 'Id of Trello board', required: true
  def create
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    Backup.new(CliSettings.settings).backup(CliSettings.board_id(options['board-id']))
  end

  desc 'list', 'List all backups'
  def list
    b = Backup.new CliSettings.settings
    b.list.each do |backup|
      puts backup
    end
  end

  desc 'show', 'Show backup of board'
  option 'board-id', desc: 'Id of Trello board', required: true
  option 'show-descriptions', desc: 'Show descriptions of cards', required: false, type: :boolean
  def show
    Backup.new(CliSettings.settings).show(CliSettings.board_id(options['board-id']), options)
  end
end
