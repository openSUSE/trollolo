require_relative 'spec_helper'

describe ScrumBoard do
  describe '#done_column' do
    it 'raises error when done column cannot be found' do
      settings = dummy_settings

      board_data = JSON.parse(load_test_file("full-board.json"))
      scrum_board = ScrumBoard.new(board_data, settings)

      settings.done_column_name_regex = /thiscolumndoesntexist/

      expect{scrum_board.done_column}.to raise_error ScrumBoard::DoneColumnNotFoundError
    end

    it 'finds done column with name "Done Sprint %s"' do
      scrum_board = ScrumBoard.new(nil, dummy_settings)

      columns = []

      column1 = double
      allow(column1).to receive(:name).and_return("Sprint Backlog")
      columns << column1

      column2 = double
      allow(column2).to receive(:name).and_return("Doing")
      columns << column2

      column3 = double
      allow(column3).to receive(:name).and_return("Done Sprint 43")
      columns << column3

      allow(scrum_board).to receive(:columns).and_return(columns)

      expect(scrum_board.done_column.name).to eq("Done Sprint 43")
    end

    it 'finds most recent done column' do
      scrum_board = ScrumBoard.new(nil, dummy_settings)

      columns = []

      column1 = double
      allow(column1).to receive(:name).and_return("Sprint Backlog")
      columns << column1

      column2 = double
      allow(column2).to receive(:name).and_return("Doing")
      columns << column2

      column3 = double
      allow(column3).to receive(:name).and_return("Done Sprint 44")
      columns << column3

      column4 = double
      allow(column4).to receive(:name).and_return("Done Sprint 43")
      columns << column4

      allow(scrum_board).to receive(:columns).and_return(columns)

      expect(scrum_board.done_column.name).to eq("Done Sprint 44")
    end

    it 'finds done column with name "Done (July 20th - August 3rd)"' do
      scrum_board = ScrumBoard.new(nil, dummy_settings)

      columns = []

      column1 = double
      allow(column1).to receive(:name).and_return("Sprint Backlog")
      columns << column1

      column2 = double
      allow(column2).to receive(:name).and_return("Doing")
      columns << column2

      column3 = double
      allow(column3).to receive(:name).and_return("Done (July 20th - August 3rd)")
      columns << column3

      allow(scrum_board).to receive(:columns).and_return(columns)

      expect(scrum_board.done_column.name).to eq("Done (July 20th - August 3rd)")
    end
  end
end
