module Scrum
  module ScrumBoards
    def sprint_board(board_id)
      Scrum::SprintBoard.new(@settings.scrum).setup(board_id)
    end

    def planning_board(board_id, list_name = nil)
      Scrum::SprintPlanningBoard.new(@settings.scrum).setup(board_id, list_name)
    end
  end
end
