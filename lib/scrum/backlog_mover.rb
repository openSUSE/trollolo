module Scrum
  class BacklogMover < TrelloService
    include ScrumBoards

    def move(planning_board, sprint_board)
      setup(planning_board, sprint_board)
      inspect_backlog
      @sprint_board.place_seabed(@seabed_card) if @seabed_card
    end

    private

    def setup(planning_board, sprint_board)
      @sprint_board = sprint_board(sprint_board)
      raise "sprint board is missing #{@sprint_board.backlog_list_name} list" unless @sprint_board.backlog_list

      @planning_board = planning_board(planning_board)
      raise 'backlog list not found on planning board' unless @planning_board.backlog_list

      @waterline_card = @planning_board.waterline_card
      @seabed_card = @planning_board.seabed_card
    end

    def inspect_backlog
      @planning_board.backlog_cards.each do |card|
        if @seabed_card && card == @seabed_card
          break
        elsif @waterline_card && card == @waterline_card
          @sprint_board.place_waterline(@waterline_card)
          puts 'under the waterline'
        else
          move_sprint_card(card) unless @planning_board.sticky?(card)
        end
      end
    end

    def move_sprint_card(card)
      puts %(moving card "#{card.name}")
      @sprint_board.receive(card)
    end
  end
end
