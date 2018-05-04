module Scrum
  module ScrumBoards
    def sprint_board(board)
      Scrum::SprintBoard.new(@settings.scrum).setup(board)
    end

    def planning_board(board, list_name = nil)
      Scrum::SprintPlanningBoard.new(@settings.scrum).setup(board, list_name)
    end
  end
end
