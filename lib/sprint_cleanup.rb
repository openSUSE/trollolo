class SprintCleanup
  SOURCE_LISTS = ["Sprint Backlog", "Doing"]
  TARGET_LIST = "Ready"

  def initialize(settings)
    @settings = settings
    init_trello
  end

  def cleanup(board_id, target_board_id)
    @board = Trello::Board.find(board_id)
    @target_board = Trello::Board.find(target_board_id)

    SOURCE_LISTS.each do |list_name|
      move_cards(@board.lists.find { |l| l.name == list_name })
    end
  end

  private

  def init_trello
    Trello.configure do |config|
      config.developer_public_key = @settings.developer_public_key
      config.member_token         = @settings.member_token
    end
  end

  def target_list
    @target_list ||= @target_board.lists.find { |l| l.name == TARGET_LIST }
  end

  def sticky?(card)
    card.labels.any? { |l| l.name == "Sticky" }
  end

  def move_cards(source_list)
    source_list.cards.each do |card|
      next if sticky?(card)
      puts %(moving card "#{card.name}" to list "#{target_list.name}")
      card.move_to_board(@target_board, target_list)
    end
  end
end
