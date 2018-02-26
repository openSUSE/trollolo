require 'securerandom'

class BoardMock
  def self.board_method(*method_names)
    method_names = [method_names] if method_names.is_a?(Symbol)

    method_names.each do |method_name|
      define_method :"#{method_name}" do
        board.send(method_name)
      end
    end
  end

  board_method :columns, :cards, :meta_cards
  board_method :open_cards
  board_method :tasks, :closed_tasks
  board_method :extra_tasks, :extra_closed_tasks
  board_method :open_columns, :todo_columns, :doing_columns, :done_column
  board_method :accepted_column, :accepted_columns
  board_method :done_story_points, :open_story_points
  board_method :extra_done_story_points, :extra_open_story_points
  board_method :unplanned_done_story_points, :unplanned_open_story_points
  board_method :unplanned_tasks, :unplanned_closed_tasks
  board_method :done_fast_lane_cards_count, :open_fast_lane_cards_count

  def initialize(settings = nil)
    @data = {
      'lists' => [],
      'cards' => []
    }
    @settings = settings
  end

  def board
    @board ||= ScrumBoard.new(@data, @settings)
  end

  def list(name)
    @current_list_id = SecureRandom.hex
    list = {
      'name' => name,
      'id' => @current_list_id
    }
    @data['lists'].push(list)
    self
  end

  def card(name)
    @current_card = {
      'name' => name,
      'id' => SecureRandom.hex,
      'idList' => @current_list_id
    }
    @data['cards'].push(@current_card)
    self
  end

  def label(name)
    @current_card['labels'] ||= []
    @current_card['labels'].push('name' => name)
    self
  end
end
