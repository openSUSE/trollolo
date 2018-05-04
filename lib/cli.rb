#  Copyright (c) 2013-2014 SUSE LLC
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 3 of the GNU General Public License as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.
#
#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

class Cli < Thor

  include CliSettings

  default_task :global

  class_option :version, type: :boolean, desc: 'Show version'
  class_option :verbose, type: :boolean, desc: 'Verbose mode'
  class_option :raw, type: :boolean, desc: 'Raw mode'

  desc 'global', 'Global options', hide: true
  def global
    if options[:version]
      puts "Trollolo: #{CliSettings.settings.version}"
    else
      Cli.help shell
    end
  end

  desc 'get SUBCOMMAND ...ARGS', 'get various types of data from board'
  subcommand 'get', CliGet

  desc 'set SUBCOMMAND ...ARGS', 'set some attributes on the board'
  subcommand 'set', CliSet

  desc 'backup SUBCOMMAND ...ARGS', 'commands to use the backup of the board'
  subcommand 'backup', CliBackup

  desc 'scrum SUBCOMMAND ...ARGS', 'commands to use the scrum workflow'
  subcommand 'scrum', CliScrum

  desc 'setup-scrum', 'Create necessary elements of our SCRUM setup'
  long_desc <<-EOT
  Will create board, lists and labels with names as configured in trollolorc,
  or use the defaults.
  EOT
  def setup_scrum
    process_global_options options
    require_trello_credentials

    c = Scrum::Creator.new(@@settings)
    c.create
  end

  desc 'set-priorities', 'Set priority text into card titles'
  long_desc <<EOT
  Add 'P<n>: ' to the beginning of every cards title in the 'Backlog' list,
  replace where already present. n is the current position of the list on
  the card.
EOT
  option 'board-id', desc: 'Id of the board', required: true
  option 'backlog-list-name', desc: 'Name of backlog list', required: false
  def set_priorities
    process_global_options options
    require_trello_credentials

    boards = Scrum::Boards.new(@@settings.scrum)
    p = Scrum::Prioritizer.new(@@settings)
    p.setup_boards(
      planning_board: boards.planning_board(board_from_id(options['board-id']),
                                            options['backlog-list-name'])
    )
    p.prioritize
  end

  desc 'cleanup-sprint', 'Move remaining cards to the planning board'
  long_desc <<EOT
  After the sprint, move remaining cards from 'Sprint Backlog', 'Doing'
  and 'QA' lists back to the planning board into the 'Ready' list.
EOT
  option 'board-id', desc: 'Id of the board', required: true
  option 'target-board-id', desc: 'Id of the target board', required: true
  option 'set-last-sprint-label', desc: 'Set true to label cards as - in the last sprint', required: false, type: :boolean, default: false
  def cleanup_sprint
    process_global_options options
    require_trello_credentials

    boards = Scrum::Boards.new(@@settings.scrum)
    s = Scrum::SprintCleaner.new(@@setting)
    s.setup_boards(
      planning_board: boards.planning_board(board_from_id(options['board-id'])),
      target_board: board_from_id(options['target-board-id'])
    )
    s.cleanup(options['set-last-sprint-label'])
  end

  desc 'move-backlog', 'Move the planning backlog to the sprint board'
  long_desc <<-EOT
  Two separate boards are used, a planning board and a sprint board for the
  current sprint.
  After each planning meeting the cards are moved from the planning boards
  'Backlog' list to the sprint boards 'Sprint Backlog' list.
  EOT
  option 'planning-board-id', desc: 'Id of the planning board', required: true
  option 'sprint-board-id', desc: 'Id of the sprint board', required: true
  def move_backlog
    process_global_options options
    require_trello_credentials

    boards = Scrum::Boards.new(@@settings.scrum)
    m = Scrum::BacklogMover.new(@@settings)
    m.setup_boards(
      planning_board: board.planning_board(board_from_id(options['planning-board-id'])),
      sprint_board: boards.sprint_board(board_from_id(options['sprint-board-id']))
    )
    m.move
  end

  private

  def process_global_options(options)
    @@settings.verbose = options[:verbose]
    @@settings.raw = options[:raw]
  end

  def require_trello_credentials
    write_back = false

    unless @@settings.developer_public_key
      puts 'Put in Trello developer public key:'
      @@settings.developer_public_key = STDIN.gets.chomp
      write_back = true
    end

    unless @@settings.member_token
      puts 'Put in Trello member token:'
      @@settings.member_token = STDIN.gets.chomp
      write_back = true
    end

    @@settings.save_config if write_back

    if !@@settings.developer_public_key || !@@settings.member_token
      STDERR.puts 'Require trello credentials in config file'
      exit 1
    end
  end

  # Returns the board_id using id_or_alias. If id_or_alias matches a mapping
  # from trollolorc then the mapped id is returned or else the id_or_alias
  # is returned.
  def board_id(id_or_alias)
    @@settings.board_aliases[id_or_alias] || id_or_alias
  end

  def board_from_id(id_or_alias)
    Trello::Board.find(board_id(id_or_alias))
  end
end
