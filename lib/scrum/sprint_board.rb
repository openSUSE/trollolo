module Scrum
  class SprintBoard
    include CardTypeDetection

    def initialize(settings)
      @under_waterline = false
      @settings = settings
    end
    attr_reader :backlog_list

    def setup(id)
      @board, @backlog_list = TrelloService.find_list(id, backlog_list_name)
      self
    end

    def backlog_list_name
      @settings.list_names['sprint_backlog']
    end

    def doing_list
      @doing_list ||= @board.lists.find { |l| l.name == doing_list_name }
    end

    def qa_list
      @qa_list ||= @board.lists.find { |l| l.name == qa_list_name }
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

    def find_waterline_label(labels)
      labels.find do |label|
        label.name == waterline_label_name ||
          label.name =~ /waterline/i
      end
    end

    def find_unplanned_label(labels)
      labels.find do |label|
        label.name =~ /unplanned/i
      end
    end

    private

    def under_waterline_label
      @label ||= find_waterline_label(@board.labels)
      @label ||= Trello::Label.create(name: waterline_label_name)
    end

    def add_waterline_label(original_card)
      new_card = @backlog_list.cards.find { |card| card.name == original_card.name }
      new_card.card_labels << under_waterline_label
    end

    def place_card_at_bottom(existing_card, planning_card)
      if existing_card
        existing_card.pos = 'bottom'
        existing_card.save
      else
        planning_card.move_to_board(@board, @backlog_list)
      end
    end

    def waterline_label_name
      @settings.label_names['waterline']
    end

    def qa_list_name
      @settings.list_names['sprint_qa']
    end

    def doing_list_name
      @settings.list_names['sprint_doing']
    end
  end
end
