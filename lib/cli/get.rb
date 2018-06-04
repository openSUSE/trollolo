class CliGet < Thor
  include CliSettings

  desc 'url [URL-FRAGMENT]', 'Get raw JSON from Trello API'
  long_desc <<-EOT
    Get raw JSON from Trello using the given URL fragment. Trollolo adds the server
    part and API version as well as the credentials from the Trollolo configuration.

    As example, the command

      trollolo get-raw lists/53186e8391ef8671265eba9f/cards?filter=open

    evaluates to the access of

      https://api.trello.com/1/lists/53186e8391ef8671265eba9f/cards?filter=open&key=xxx&token=yyy
  EOT
  def url(url_fragment)
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    url = "https://api.trello.com/1/#{url_fragment}"
    if url_fragment =~ /\?/
      url += '&'
    else
      url += '?'
    end
    url += "key=#{CliSettings.settings.developer_public_key}&token=#{CliSettings.settings.member_token}"
    STDERR.puts "Calling #{url}"

    response = Net::HTTP.get_response(URI.parse(url))
    print JSON.pretty_generate(JSON.parse(response.body))
  end

  desc 'lists', 'Get lists'
  option 'board-id', desc: 'Id of Trello board', required: true
  def lists
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    trello = TrelloWrapper.new(CliSettings.settings)
    board = trello.board(CliSettings.board_id(options['board-id']))
    lists = board.columns

    if CliSettings.settings.raw
      puts JSON.pretty_generate lists
    else
      lists.each do |list|
        puts list.name
      end
    end
  end

  desc 'cards', 'Get cards'
  option 'board-id', desc: 'Id of Trello board', required: true
  def cards
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    trello = TrelloWrapper.new(CliSettings.settings)
    board = trello.board(CliSettings.board_id(options['board-id']))
    cards = board.cards

    if CliSettings.settings.raw
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

  desc 'checklists', 'Get checklists'
  option 'board-id', desc: 'Id of Trello board', required: true
  def checklists
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    trello = TrelloWrapper.new(CliSettings.settings)
    board = trello.board(CliSettings.board_id(options['board-id']))
    board.cards.each do |card|
      card.checklists.each do |checklist|
        puts checklist.name
      end
    end
  end

  desc 'organization', 'Show organization info'
  option 'org-name', desc: 'Name of organization', required: true
  def organization
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    organization = TrelloWrapper.new(CliSettings.settings).organization(options['org-name'])

    puts "Display Name: #{organization.display_name}"
    puts "Home page: #{organization.url}"
  end

  desc 'description', 'Reads description'
  option 'card-id', desc: 'Id of card', required: true
  def description
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    trello = TrelloWrapper.new(CliSettings.settings)

    puts trello.get_description(options['card-id'])
  end

  desc 'members', 'Show organization members'
  option 'org-name', desc: 'Name of organization', required: true
  def members
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    trello = TrelloWrapper.new(CliSettings.settings)

    members = trello.organization(options['org-name']).members.sort_by(&:username)

    members.each do |member|
      puts "#{member.username} (#{member.full_name})"
    end
  end

  desc 'boards', 'List name and id of all boards'
  option 'member-id', desc: 'Id of the member', required: true
  def boards
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    trello = TrelloWrapper.new(CliSettings.settings)
    trello.get_member_boards(options['member-id']).sort_by do |board|
      board['name']
    end.each do |board|
      puts "#{board['name']} - #{board['id']}"
    end
  end
end
