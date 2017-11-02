module Scrum
  class SprintPlanningBoard
    include CardTypeDetection

    attr_reader :backlog_list_name

    def initialize(settings)
      @settings = settings
      @backlog_list_name = settings.list_names['planning_backlog']
    end

    attr_accessor :backlog_list

    def setup(id, list_name = nil)
      @backlog_list_name = list_name if list_name
      @board, @backlog_list = TrelloService.find_list(id, @backlog_list_name)
      self
    end

    def backlog_cards
      @backlog_list.cards
    end
  end
end
