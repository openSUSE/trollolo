module Scrum
  class Boards
    def initialize(settings)
      @settings = settings
    end

    def sprint_board(board)
      sprint = Scrum::SprintBoard.new(@settings).setup(board)
      raise "sprint board is missing the backlog list named: '#{sprint.backlog_list_name}'" unless sprint.backlog_list
      sprint
    end

    def planning_board(board, list_name = nil)
      planning = Scrum::SprintPlanningBoard.new(@settings).setup(board, list_name)
      raise "planning board is missing the backlog list named: '#{planning.backlog_list_name}'" unless planning.backlog_list
      planning
    end
  end
end
