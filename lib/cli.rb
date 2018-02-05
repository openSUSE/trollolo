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

  default_task :global

  class_option :version, type: :boolean, desc: 'Show version'
  class_option :verbose, type: :boolean, desc: 'Verbose mode'
  class_option :raw, type: :boolean, desc: 'Raw mode'
  class_option 'board-id', type: :string, desc: 'id of Trello board'

  def self.settings=(s)
    @@settings = s
  end

  desc 'global', 'Global options', hide: true
  def global
    if options[:version]
      puts "Trollolo: #{@@settings.version}"
    else
      Cli.help shell
    end
  end

  desc 'get-raw [URL-FRAGMENT]', 'Get raw JSON from Trello API'
  long_desc <<EOT
Get raw JSON from Trello using the given URL fragment. Trollolo adds the server
part and API version as well as the credentials from the Trollolo configuration.

As example, the command

  trollolo get-raw lists/53186e8391ef8671265eba9f/cards?filter=open

evaluates to the access of

  https://api.trello.com/1/lists/53186e8391ef8671265eba9f/cards?filter=open&key=xxx&token=yyy
EOT

  def get_raw(url_fragment)
    process_global_options options
    require_trello_credentials

    url = "https://api.trello.com/1/#{url_fragment}"
    if url_fragment =~ /\?/
      url += '&'
    else
      url += '?'
    end
    url += "key=#{@@settings.developer_public_key}&token=#{@@settings.member_token}"
    STDERR.puts "Calling #{url}"

    response = Net::HTTP.get_response(URI.parse(url))
    print JSON.pretty_generate(JSON.parse(response.body))
  end

  desc 'get-lists', 'Get lists'
  option 'board-id', desc: 'Id of Trello board', required: true
  def get_lists
    process_global_options options
    require_trello_credentials

    trello = TrelloWrapper.new(@@settings)
    board = trello.board(board_id(options['board-id']))
    lists = board.columns

    if @@settings.raw
      puts JSON.pretty_generate lists
    else
      lists.each do |list|
        puts list.name
      end
    end
  end

  desc 'get-cards', 'Get cards'
  option 'board-id', desc: 'Id of Trello board', required: true
  def get_cards
    process_global_options options
    require_trello_credentials

    trello = TrelloWrapper.new(@@settings)
    board = trello.board(board_id(options['board-id']))
    cards = board.cards

    if @@settings.raw
      cards_as_json = []
      cards.each do |card|
        cards_as_json.push(card.as_json)
      end
      puts '['
      puts cards_as_json.join(',')
      puts ']'
    else
      cards.each do |card|
        puts card.name
      end
    end
  end

  desc 'get-checklists', 'Get checklists'
  option 'board-id', desc: 'Id of Trello board', required: true
  def get_checklists
    process_global_options options
    require_trello_credentials

    trello = TrelloWrapper.new(@@settings)
    board = trello.board(board_id(options['board-id']))
    board.cards.each do |card|
      card.checklists.each do |checklist|
        puts checklist.name
      end
    end
  end

  desc 'burndowns', 'run multiple burndowns'
  option 'board-list', desc: 'path to board-list.yaml', required: true
  option :plot, type: :boolean, desc: 'also plot the new data'
  option :output, aliases: :o, desc: 'Output directory'
  def burndowns
    process_global_options options
    board_list = YAML.load_file(options['board-list'])
    board_list.each_key do |name|
      raise 'invalid character in team name' if name =~ /[^[:alnum:]. _]/ # sanitize
      board = board_list[name]
      if options['output']
        destdir = File.join(options['output'], name)
      else
        destdir = name
      end
      chart = BurndownChart.new @@settings
      chart.setup(destdir, board['boardid']) unless File.directory?(destdir)
      chart.update('output' => destdir, plot: options[:plot])
    end
  end

  desc 'burndown-init', 'Initialize burndown chart'
  option :output, aliases: :o, desc: 'Output directory', required: false
  option 'board-id', desc: 'Id of Trello board', required: true
  def burndown_init(command = nil)
    process_global_options options
    require_trello_credentials

    chart = BurndownChart.new @@settings
    puts 'Preparing directory...'
    chart.setup(options[:output] || Dir.pwd, board_id(options['board-id']))
  end

  desc 'burndown', 'Update burndown chart'
  option :output, aliases: :o, desc: 'Output directory', required: false
  option :new_sprint, aliases: :n, desc: 'Create new sprint'
  option :sprint_number, type: :numeric, desc: 'Provide the number of the sprint'
  option :total_days, type: :numeric, desc: 'Provide how many days the sprint longs. 10 days by default'
  option :weekend_lines, type: :array, desc: 'Set the weekend_lines. [3.5, 8.5] by default'
  option :plot, type: :boolean, desc: 'also plot the new data'
  option :plot_to_board, type: :boolean, desc: 'Send the plotted data to the board'
  option 'with-fast-lane', desc: 'Plot Fast Lane with new cards bars', required: false, type: :boolean
  option 'no-tasks', desc: 'Do not plot tasks line', required: false, type: :boolean
  option 'push-to-api', desc: 'Push collected data to api endpoint (in json)', required: false
  option 'board-id', desc: 'Id of Trello Board'
  def burndown
    process_global_options options
    require_trello_credentials

    chart = BurndownChart.new @@settings
    begin
      if options[:new_sprint]
        chart.create_next_sprint(options[:output] || Dir.pwd, options)
      end
      chart.update(options)
      puts "Updated data for sprint #{chart.sprint}"
    rescue TrolloloError => e
      STDERR.puts e
      exit 1
    end
  end

  desc 'plot SPRINT-NUMBER [--output] [--no-tasks] [--with-fast-lane]', 'Plot burndown chart for given sprint'
  option :output, aliases: :o, desc: 'Output directory', required: false
  option 'with-fast-lane', desc: 'Plot Fast Lane with new cards bars', required: false, type: :boolean
  option 'no-tasks', desc: 'Do not plot tasks line', required: false, type: :boolean
  def plot(sprint_number)
    process_global_options options
    BurndownChart.plot(sprint_number, options)
  end

  desc 'backup', 'Create backup of board'
  option 'board-id', desc: 'Id of Trello board', required: true
  def backup
    process_global_options options
    require_trello_credentials

    Backup.new(@@settings).backup(board_id(options['board-id']))
  end

  desc 'list-backups', 'List all backups'
  def list_backups
    b = Backup.new @@settings
    b.list.each do |backup|
      puts backup
    end
  end

  desc 'show-backup', 'Show backup of board'
  option 'board-id', desc: 'Id of Trello board', required: true
  option 'show-descriptions', desc: 'Show descriptions of cards', required: false, type: :boolean
  def show_backup
    Backup.new(@@settings).show(board_id(options['board-id']), options)
  end

  desc 'organization', 'Show organization info'
  option 'org-name', desc: 'Name of organization', required: true
  def organization
    process_global_options options
    require_trello_credentials

    organization = TrelloWrapper.new(@@settings).organization(options['org-name'])

    puts "Display Name: #{organization.display_name}"
    puts "Home page: #{organization.url}"
  end

  desc 'get-description', 'Reads description'
  option 'card-id', desc: 'Id of card', required: true
  def get_description
    process_global_options options
    require_trello_credentials

    trello = TrelloWrapper.new(@@settings)

    puts trello.get_description(options['card-id'])
  end

  desc 'set-description', 'Writes description read from standard input'
  option 'card-id', desc: 'Id of card', required: true
  def set_description
    process_global_options options
    require_trello_credentials

    TrelloWrapper.new(@@settings).set_description(options['card-id'], STDIN.read)
  end

  desc 'organization-members', 'Show organization members'
  option 'org-name', desc: 'Name of organization', required: true
  def organization_members
    process_global_options options
    require_trello_credentials

    trello = TrelloWrapper.new(@@settings)

    members = trello.organization(options['org-name']).members.sort_by(&:username)

    members.each do |member|
      puts "#{member.username} (#{member.full_name})"
    end
  end

  desc 'set-cover <filename>', 'Set cover picture'
  option 'card-id', desc: 'Id of card', required: true
  def set_cover(filename)
    process_global_options(options)
    require_trello_credentials

    TrelloWrapper.new(@@settings).add_attachment(options['card-id'], filename)
  end

  desc 'make-cover <filename>', 'Make existing picture the cover'
  option 'card-id', desc: 'Id of card', required: true
  def make_cover(filename)
    process_global_options(options)
    require_trello_credentials

    TrelloWrapper.new(@@settings).make_cover(options['card-id'], filename)
  end

  desc 'list-member-boards', 'List name and id of all boards'
  option 'member-id', desc: 'Id of the member', required: true
  def list_member_boards
    process_global_options options
    require_trello_credentials

    trello = TrelloWrapper.new(@@settings)
    trello.get_member_boards(options['member-id']).sort_by do |board|
      board['name']
    end.each do |board|
      puts "#{board['name']} - #{board['id']}"
    end
  end

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

    p = Scrum::Prioritizer.new(@@settings)
    p.prioritize(board_id(options['board-id']), options['backlog-list-name'])
  end

  desc 'cleanup-sprint', 'Move remaining cards to the planning board'
  long_desc <<EOT
  After the sprint, move remaining cards from 'Sprint Backlog', 'Doing'
  and 'QA' lists back to the planning board into the 'Ready' list.
EOT
  option 'board-id', desc: 'Id of the board', required: true
  option 'target-board-id', desc: 'Id of the target board', required: true
  def cleanup_sprint
    process_global_options options
    require_trello_credentials

    s = Scrum::SprintCleaner.new(@@settings)
    s.cleanup(board_id(options['board-id']),
              board_id(options['target-board-id']))
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

    m = Scrum::BacklogMover.new(@@settings)
    m.move(board_id(options['planning-board-id']), board_id(options['sprint-board-id']))
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
end
