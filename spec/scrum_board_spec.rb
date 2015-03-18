require 'spec_helper'

describe ScrumBoard do
  describe '#done_column' do
    before(:each) do
      @settings = dummy_settings

      board_data = JSON.parse(load_test_file("full-board.json"))
      @scrum_board = ScrumBoard.new(board_data, @settings)
    end

    it 'raises error when done column cannot be found' do
      @settings.done_column_name_regex = /thiscolumndoesntexist/

      expect{@scrum_board.done_column}.to raise_error ScrumBoard::DoneColumnNotFoundError
    end
  end
end
