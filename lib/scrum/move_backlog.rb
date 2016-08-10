module Scrum
  class MoveBacklog < TrelloService
    def move(planning_board_id, sprint_board_id)
      setup(planning_board_id, sprint_board_id)
      inspect_backlog
      @sprint_board.place_seabed(@seabed_card)
    end

    private

    def setup(planning_board_id, sprint_board_id)
      @sprint_board = SprintBoard.new(sprint_board_id)
      fail "sprint board is missing #{@sprint_board.backlog_list_name} list" unless @sprint_board.backlog_list

      @planning_board = SprintPlanningBoard.new(planning_board_id)
      fail "backlog list not found on planning board" unless @planning_board.backlog_list

      @waterline_card = @planning_board.waterline_card
      fail "backlog list on planning board is missing waterline or seabed card"  unless @waterline_card

      @seabed_card = @planning_board.seabed_card
      fail "backlog list on planning board is missing waterline or seabed card"  unless @seabed_card
    end

    def inspect_backlog
      @planning_board.backlog_cards.each do |card|
        if card == @seabed_card
          break

        elsif card == @waterline_card
          @sprint_board.place_waterline(@waterline_card)

        else
          move_sprint_card(card)
        end
      end
    end

    def move_sprint_card(card)
      puts %(moving card "#{card.name}")
      @sprint_board.receive(card)
    end
  end
end
