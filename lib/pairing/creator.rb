module Pairing
  class Creator < TrelloService
    def create
      @pairing = @settings.pairing
      create_pairing_board
    end

    private

    def create_labels(board_id)
      @pairing.label_names.each_value { |name| Trello::Label.create(name: name, board_id: board_id) }
    end

    def create_pairing_board
      board = Trello::Board.create(name: @pairing.board_names['pairing'])
      Trello::List.create(board_id: board.id, name: @pairing.list_names['tracks'])
      Trello::List.create(board_id: board.id, name: @pairing.list_names['devs'])
      create_labels(board.id)
    end
  end
end
