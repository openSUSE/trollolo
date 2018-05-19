require 'ostruct'

module BoardLocator
  def setup_boards(args = {})
    @boards = OpenStruct.new(args)
    self
  end
end
