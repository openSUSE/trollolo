module Scrum
  class Prioritizer < TrelloService
    def prioritize(board_id)
      @board = SprintPlanningBoard.new.setup(board_id)
      fail "list named 'Backlog' not found on board" unless @board.backlog_list
      update_priorities
    end

    private

    def update_priorities
      priority_name = PriorityName.new
      n = 1
      @board.backlog_cards.each do |card|
        next if @board.sticky?(card) || @board.waterline?(card)
        puts %(set priority to #{n} for "#{card.name}")
        card.name = priority_name.build(card.name, n)
        card.save
        n += 1
      end
    end
  end
end
