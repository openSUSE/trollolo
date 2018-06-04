class CliScrum < Thor
  include CliSettings

  desc 'init', 'Create necessary elements of our SCRUM setup'
  long_desc <<-EOT
  Will create board, lists and labels with names as configured in trollolorc,
  or use the defaults.
  EOT
  def init
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    c = Scrum::Creator.new(CliSettings.settings)
    c.create
  end

  desc 'prioritize', 'Set priority text into card titles'
  long_desc <<-EOT
  Add 'P<n>: ' to the beginning of every cards title in the 'Backlog' list,
  replace where already present. n is the current position of the list on
  the card.
  EOT
  option 'board-id', desc: 'Id of the board', required: true
  option 'backlog-list-name', desc: 'Name of backlog list', required: false
  def prioritize
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    boards = Scrum::Boards.new(CliSettings.settings.scrum)
    p = Scrum::Prioritizer.new(CliSettings.settings)
    p.setup_boards(
      planning_board: boards.planning_board(CliSettings.board_from_id(options['board-id']),
                                            options['backlog-list-name'])
    )
    p.prioritize
  end

  desc 'end', 'Move remaining cards to the planning board'
  long_desc <<-EOT
  After the sprint, move remaining cards from 'Sprint Backlog', 'Doing'
  and 'QA' lists back to the planning board into the 'Ready' list.
  EOT
  option 'board-id', desc: 'Id of the board', required: true
  option 'target-board-id', desc: 'Id of the target board', required: true
  def end_sprint
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    s = Scrum::SprintCleaner.new(CliSettings.settings)
    s.cleanup(CliSettings.board_id(options['board-id']),
              CliSettings.board_id(options['target-board-id']))
  end

  desc 'start', 'Move the planning backlog to the sprint board'
  long_desc <<-EOT
  Two separate boards are used, a planning board and a sprint board for the
  current sprint.
  After each planning meeting the cards are moved from the planning boards
  'Backlog' list to the sprint boards 'Sprint Backlog' list.
  EOT
  option 'planning-board-id', desc: 'Id of the planning board', required: true
  option 'sprint-board-id', desc: 'Id of the sprint board', required: true
  def start
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    m = Scrum::BacklogMover.new(CliSettings.settings)
    m.move(CliSettings.board_id(options['planning-board-id']), CliSettings.board_id(options['sprint-board-id']))
  end

  desc 'backlog', 'Show backlog of board'
  option 'board-id', desc: 'Id of Trello board', required: true
  def backlog
    puts '| Title'

    trello = TrelloWrapper.new(CliSettings.settings)
    board = trello.board(options['board-id'])
    board.planning_backlog_column.cards.each do |card|
      puts "| #{card.name}"
    end
  end
end
