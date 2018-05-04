module Scrum
  class SprintPlanningBoard
    include CardTypeDetection
    include TrelloHelpers

    attr_reader :backlog_list_name

    def initialize(settings)
      @settings = settings
      @backlog_list_name = settings.list_names['planning_backlog']
    end

    attr_accessor :backlog_list

    def setup(board, list_name = nil)
      @board = board
      @backlog_list_name = list_name if list_name
      @backlog_list = find_list(@backlog_list_name)
      self
    end

    def backlog_cards
      @backlog_list.cards
    end
  end
end
