module TrelloHelpers
  def find_list(name)
    @board.lists.find { |l| l.name == name }
  end
end
