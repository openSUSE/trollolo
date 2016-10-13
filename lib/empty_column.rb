class EmptyColumn < Column
  def initialize
    super({"lists" => [], "cards" => []}, nil)
  end
end
