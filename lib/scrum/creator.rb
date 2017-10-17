module Scrum
  class Creator < TrelloService
    def create
      @scrum = @settings.scrum
      create_sprint_board
      create_planning_board
    end

    private

    def create_labels(board_id)
      @scrum.label_names.each { |_, name| Trello::Label.create(name: name, board_id: board_id) }
    end

    def create_sprint_board
      board = Trello::Board.create(name: @scrum.board_names['sprint'])
      Trello::List.create(board_id: board.id, name: @scrum.list_names['sprint_backlog'])
      Trello::List.create(board_id: board.id, name: @scrum.list_names['sprint_qa'])
      Trello::List.create(board_id: board.id, name: @scrum.list_names['sprint_doing'])
      create_labels(board.id)
    end

    def create_planning_board
      board = Trello::Board.create(name: @scrum.board_names['planning'])
      Trello::List.create(board_id: board.id, name: @scrum.list_names['planning_backlog'])
      Trello::List.create(board_id: board.id, name: @scrum.list_names['planning_ready'])
      create_labels(board.id)
    end
  end
end
