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

  desc 'show-diff', 'Show diff backup of board from online'
  option 'board-id', desc: 'Id of Trello board', required: true
  option 'board-version', desc: 'Version of Trello board', required: true
  option 'second-board-version', desc: 'Second Local Version of Trello board'
  def show_diff
    backup = Backup.new(CliSettings.settings)
    output_diff = backup.show_diff(CliSettings.board_id(options['board-id']), options['board-version'], options['second-board-version'])

    pp output_diff
  end
end
