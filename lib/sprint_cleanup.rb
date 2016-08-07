class SprintCleanup < TrelloService
  SOURCE_LISTS = ["Sprint Backlog", "Doing"]
  TARGET_LIST = "Ready"

  def cleanup(board_id, target_board_id)
    @board = Trello::Board.find(board_id)
    @target_board = Trello::Board.find(target_board_id)

    SOURCE_LISTS.each do |list_name|
      move_cards(@board.lists.find { |l| l.name == list_name })
    end
  end

  private

  def target_list
    @target_list ||= @target_board.lists.find { |l| l.name == TARGET_LIST }
  end

  def waterline_label(card)
    card.labels.find { |label| label.name =~ /waterline/i }
  end

  def remove_waterline_label(card)
    label = waterline_label(card)
    card.remove_label(label) if label
  end

  def move_cards(source_list)
    source_list.cards.each do |card|
      next if sticky?(card)
      puts %(moving card "#{card.name}" to list "#{target_list.name}")
      card.members.each { |member| card.remove_member(member) }
      remove_waterline_label(card)
      card.move_to_board(@target_board, target_list)
    end
  end
end
