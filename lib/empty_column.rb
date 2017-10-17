class EmptyColumn < Column
  def initialize(settings = nil)
    super({'lists' => [], 'cards' => []}, nil, settings)
  end
end
