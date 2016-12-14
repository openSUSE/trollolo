module Scrum
  class SprintPlanningBoard
    include CardTypeDetection

    def initialize(settings)
      @settings = settings
    end
    attr_accessor :backlog_list

    def setup(id)
      @board, @backlog_list = TrelloService.find_list(id, @settings.list_names["planning_backlog"])
      self
    end

    def backlog_cards
      @backlog_list.cards
    end
  end
end
