class CliSet < Thor
  include CliSettings

  desc 'description', 'Writes description read from standard input'
  option 'card-id', desc: 'Id of card', required: true
  def description
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    TrelloWrapper.new(CliSettings.settings).set_description(options['card-id'], STDIN.read)
  end

  desc 'cover <filename>', 'Make existing picture the cover'
  option 'card-id', desc: 'Id of card', required: true
  def cover(filename)
    CliSettings.process_global_options(options)
    CliSettings.require_trello_credentials

    TrelloWrapper.new(CliSettings.settings).make_cover(options['card-id'], filename)
  end
end
