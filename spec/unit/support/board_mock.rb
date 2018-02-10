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

  board_method :columns, :cards

  def initialize
    @data = {
      'lists' => [],
      'cards' => []
    }
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
