class TrelloService
  def initialize(settings)
    @settings = settings
    init_trello
  end

  def sticky?(card)
    card.labels.any? { |l| l.name == "Sticky" }
  end

  protected

  def init_trello
    Trello.configure do |config|
      config.developer_public_key = @settings.developer_public_key
      config.member_token         = @settings.member_token
    end
  end
end
