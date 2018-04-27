class TrelloService
  attr_reader :settings

  def initialize(settings)
    @settings = settings
    init_trello
  end

  def self.find_list(board_id, name)
    board = Trello::Board.find(board_id)
    [board, board.lists.find { |l| l.name == name }]
  end

  protected

  def init_trello
    Trello.configure do |config|
      config.developer_public_key = @settings.developer_public_key
      config.member_token         = @settings.member_token
    end
  end
end
