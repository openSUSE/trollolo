module Scrum
  class SprintPlanningBoard
    include CardTypeDetection

    PLANNING_BACKLOG_LIST = "Backlog"

    attr_accessor :backlog_list

    def setup(id)
      @board, @backlog_list = TrelloService.find_list(id, PLANNING_BACKLOG_LIST)
      self
    end

    def backlog_cards
      @backlog_list.cards
    end
  end
end
