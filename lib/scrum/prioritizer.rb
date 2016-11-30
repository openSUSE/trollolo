module Scrum
  class Prioritizer

    def initialize(settings)
      @settings = settings
    end

    def prioritize(board_id, list_name)
      list = find_list(board_id, list_name)
      fail "list not found on board" unless list
      update_priorities(list)
    end

    private

    def trello
      @trello ||= TrelloWrapper.new(@settings)
    end

    def update_priorities(list)
      n = 1
      list.cards.each do |card|
        next if card.card_labels.any? { |label| label["name"] == "Sticky" }
        card.priority = n
        trello.set_name(card.id, card.name)
        puts %(set priority to #{n} for "#{card.name}")
        n += 1
      end
    end

    def find_list(board_id, list_name)
      board = trello.board(board_id)
      board.columns.find { |list| list.name == list_name }
    end
  end
end
