module Scrum
  class SprintPlanningBoard
    include CardTypeDetection

    PLANNING_BACKLOG_LIST = "Backlog"

    def initialize(id)
      @board, @backlog_list = TrelloService.find_list(id, PLANNING_BACKLOG_LIST)
    end
    attr_accessor :backlog_list

    def backlog_cards
      @backlog_list.cards
    end

    def waterline_card
      @backlog_list.cards.find { |card| is_waterline?(card) }
    end

    def seabed_card
      @backlog_list.cards.find { |card| is_seabed?(card) }
    end
  end
end
