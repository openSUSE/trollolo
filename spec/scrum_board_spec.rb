require 'spec_helper'

describe ScrumBoard do
  describe '#done_column' do
    before(:each) do
      allow_any_instance_of(ScrumBoard).to receive(:retrieve_data).
        and_return(JSON.parse(load_test_file("full-board.json")))

      @settings = dummy_settings
      @scrum_board = ScrumBoard.new(double("Trello Board"), @settings)
    end

    it 'raises error when done column cannot be found' do
      @settings.done_column_name_regex = /thiscolumndoesntexist/

      expect{@scrum_board.done_column}.to raise_error ScrumBoard::DoneColumnNotFoundError
    end
  end
end
