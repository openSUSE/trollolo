class SprintCleanup
  SOURCE_LISTS = ["Sprint Backlog", "Doing"]
  TARGET_LIST = "Ready"

  def initialize(settings)
    @settings = settings
  end

  def cleanup(board_id, target_board_id)
    @board_id = board_id
    @target_board_id = target_board_id

    SOURCE_LISTS.each do |list_name|
      move_cards(trello.find_list(@board_id, list_name))
    end
  end

  private

  def trello
    @trello ||= TrelloWrapper.new(@settings)
  end

  def target_list
    @target_list ||= trello.find_list(@target_board_id, TARGET_LIST)
  end

  def sticky?(card)
    card["labels"].any? { |l| l["name"] == "Sticky" }
  end

  def move_cards(source_list)
    trello.get_cards_from_list(source_list.id).each do |card|
      next if sticky?(card)
      card = Trello::Card.find(card["id"])
      puts %(moving card "#{card.name}" to list "#{target_list.name}")
      card.move_to_board(Trello::Board.find(@target_board_id), target_list)
    end
  end
end
