class TrelloService
  require 'ostruct'

  attr_reader :settings

  def initialize(settings, boards = {})
    @settings = settings
    @boards = OpenStruct.new(boards)

    init_trello
  end

  protected

  def init_trello
    Trello.configure do |config|
      config.developer_public_key = @settings.developer_public_key
      config.member_token         = @settings.member_token
    end
  end
end
