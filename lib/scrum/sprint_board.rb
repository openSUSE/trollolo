module Scrum
  class SprintBoard
    include CardTypeDetection

    def initialize
      @under_waterline = false
    end
    attr_reader :backlog_list

    def setup(id)
      @board, @backlog_list = TrelloService.find_list(id, backlog_list_name)
      self
    end

    def backlog_list_name
      "Sprint Backlog"
    end

    def qa_list_name
      "QA"
    end

    def doing_list_name
      "Doing"
    end

    def doing_list
      @board.lists.find { |l| l.name == doing_list_name }
    end

    def qa_list
      @board.lists.find { |l| l.name == qa_list_name }
    end

    def receive(card)
      card.move_to_board(@board, @backlog_list)
      add_waterline_label(card) if @under_waterline
    end

    def place_waterline(planning_waterline_card)
      place_card_at_bottom(waterline_card, planning_waterline_card)
      @under_waterline = true
    end

    def place_seabed(planning_seabed_card)
      place_card_at_bottom(seabed_card, planning_seabed_card)
    end

    private

    def under_waterline_label
      @label ||= @board.labels.find { |label| label.name =~ /under waterline/i }
      @label ||= Trello::Label.create(name: 'Under waterline')
    end

    def add_waterline_label(original_card)
      new_card = @backlog_list.cards.find { |card| card.name == original_card.name }
      new_card.card_labels << under_waterline_label
    end

    def place_card_at_bottom(existing_card, planning_card)
      if existing_card
        existing_card.pos = 'bottom'
        existing_card.save
        planning_card.delete
      else
        planning_card.move_to_board(@board, @backlog_list)
      end
    end
  end
end
