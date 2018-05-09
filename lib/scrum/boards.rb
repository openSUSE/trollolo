module Scrum
  class Boards
    def initialize(settings)
      @settings = settings
    end

    def sprint_board(board)
      Scrum::SprintBoard.new(@settings).setup(board)
    end

    def planning_board(board, list_name = nil)
      Scrum::SprintPlanningBoard.new(@settings).setup(board, list_name)
    end
  end
end
