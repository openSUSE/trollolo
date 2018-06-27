module Scrum
  class Prioritizer < TrelloService
    include BoardLocator

    def prioritize
      load
      update_priorities
    end

    private

    def load
      @board = @boards.planning_board
    end

    def update_priorities
      n = 1
      @board.backlog_cards.each do |card|
        next if @board.sticky?(card) || @board.waterline?(card)
        card.name = PriorityName.build(card.name, n)
        card.save
        puts %(set priority to #{n} for "#{card.name}")
        n += 1
      end
    end
  end
end
