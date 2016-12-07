module Scrum
  class SprintCleaner < TrelloService
    TARGET_LIST = "Ready"

    def cleanup(board_id, target_board_id)
      @board = SprintBoard.new.setup(board_id)
      @target_board = Trello::Board.find(target_board_id)

      move_cards(@board.backlog_list)
      move_cards(@board.doing_list) if @board.doing_list
      move_cards(@board.qa_list) if @board.qa_list
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
        next if @board.sticky?(card)
        puts %(moving card "#{card.name}" to list "#{target_list.name}")
        card.members.each { |member| card.remove_member(member) }
        remove_waterline_label(card)
        card.move_to_board(@target_board, target_list)
      end
    end
  end
end
