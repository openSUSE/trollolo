class MoveBacklog < TrelloService
  SPRINT_BACKLOG_LIST = "Sprint Backlog"
  PLANNING_BACKLOG_LIST = "Backlog"

  def move(planning_board_id, sprint_board_id)
    setup(planning_board_id, sprint_board_id)
    inspect_backlog
    place_seabed
  end

  private

  def setup(planning_board_id, sprint_board_id)
    @sprint_board, @sprint_backlog = find_list(sprint_board_id, SPRINT_BACKLOG_LIST)
    fail "sprint board is missing #{SPRINT_BACKLOG_LIST} list" unless @sprint_backlog

    @planning_board, @planning_list = find_list(planning_board_id, PLANNING_BACKLOG_LIST)
    fail "backlog list not found on planning board" unless @planning_list

    @waterline_card = @planning_list.cards.find { |card| is_waterline?(card) }
    fail "backlog list on planning board is missing waterline or seabed card"  unless @waterline_card

    @seabed_card = @planning_list.cards.find { |card| is_seabed?(card) }
    fail "backlog list on planning board is missing waterline or seabed card"  unless @seabed_card
  end

  def inspect_backlog
    @under_waterline = false
    @planning_list.cards.each do |card|
      if card == @seabed_card
        break

      elsif card == @waterline_card
        place_waterline
        @under_waterline = true

      else
        move_sprint_card(card)
      end
    end
  end

  def move_sprint_card(card)
    puts %(moving card "#{card.name}")
    card.move_to_board(@sprint_board, @sprint_backlog)
    add_waterline_label(card) if @under_waterline
  end

  def add_waterline_label(original_card)
    new_card = @sprint_backlog.cards.find { |card| card.name == original_card.name }
    new_card.card_labels << under_waterline_label
  end

  def place_waterline
    existing_card = @sprint_board.cards.find { |card| is_waterline?(card) }
    if existing_card
      existing_card.move_to_list(@sprint_backlog)
      @waterline_card.delete
    else
      @waterline_card.move_to_board(@sprint_board, @sprint_backlog)
    end
  end

  def place_seabed
    existing_card = @sprint_board.cards.find { |card| is_seabed?(card) }
    if existing_card
      existing_card.move_to_list(@sprint_backlog)
      @seabed_card.delete
    else
      @seabed_card.move_to_board(@sprint_board, @sprint_backlog)
    end
  end

  def under_waterline_label
    @label ||= @sprint_board.labels.find { |label| label.name =~ /under waterline/i }
    @label ||= Trello::Label.create(name: 'Under waterline')
  end

  def is_waterline?(card)
    card.name =~ /w.?a.?t.?e.?r.?l.?i.?n.?e/i
  end

  def is_seabed?(card)
    card.name =~ /s.?e.?a.?b.?e.?d/i
  end

  def find_list(board_id, name)
    board = Trello::Board.find(board_id)
    return board, board.lists.find { |l| l.name == name }
  end
end
