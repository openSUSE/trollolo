require_relative 'spec_helper'

describe ScrumBoard do
  describe '#todo_column' do
    let(:board) { ScrumBoard.new(JSON.parse(load_test_file('full-board.json')), dummy_settings) }

    it 'finds column' do
      expect(board.todo_column.name).to eq('Sprint Backlog')
    end
  end

  describe '#doing_columns' do
    let(:board) { ScrumBoard.new(JSON.parse(load_test_file('full-board.json')), dummy_settings) }

    it 'finds columns' do
      expect(board.doing_columns.count).to eq(1)
      expect(board.doing_columns.first.name).to eq('Doing')
    end
  end

  describe '#done_column' do
    it 'raises error when done column cannot be found' do
      settings = dummy_settings

      board_data = JSON.parse(load_test_file('full-board.json'))
      scrum_board = ScrumBoard.new(board_data, settings)

      settings.done_column_name_regex = /thiscolumndoesntexist/

      expect{scrum_board.done_column}.to raise_error ScrumBoard::DoneColumnNotFoundError
    end

    it 'finds done column with name "Done Sprint %s"' do
      scrum_board = ScrumBoard.new(nil, dummy_settings)

      columns = []

      column1 = double
      allow(column1).to receive(:name).and_return('Sprint Backlog')
      columns << column1

      column2 = double
      allow(column2).to receive(:name).and_return('Doing')
      columns << column2

      column3 = double
      allow(column3).to receive(:name).and_return('Done Sprint 43')
      columns << column3

      allow(scrum_board).to receive(:columns).and_return(columns)

      expect(scrum_board.done_column.name).to eq('Done Sprint 43')
    end

    it 'finds done column with name "Done Sprint %s" if there are multiple done columns' do
      scrum_board = ScrumBoard.new(nil, dummy_settings)

      columns = []

      column1 = double
      allow(column1).to receive(:name).and_return('Sprint Backlog')
      columns << column1

      column2 = double
      allow(column2).to receive(:name).and_return('Doing')
      columns << column2

      column3 = double
      allow(column3).to receive(:name).and_return('Done Sprint 44')
      columns << column3

      column4 = double
      allow(column4).to receive(:name).and_return('Done Sprint 43')
      columns << column4

      allow(scrum_board).to receive(:columns).and_return(columns)

      expect(scrum_board.done_column.name).to eq('Done Sprint 44')
    end

    it 'finds done column with name "Done (July 20th - August 3rd)"' do
      scrum_board = ScrumBoard.new(nil, dummy_settings)

      columns = []

      column1 = double
      allow(column1).to receive(:name).and_return('Sprint Backlog')
      columns << column1

      column2 = double
      allow(column2).to receive(:name).and_return('Doing')
      columns << column2

      column3 = double
      allow(column3).to receive(:name).and_return('Done (July 20th - August 3rd)')
      columns << column3

      allow(scrum_board).to receive(:columns).and_return(columns)

      expect(scrum_board.done_column.name).to eq('Done (July 20th - August 3rd)')
    end
  end

  describe 'card counts' do
    context 'full board' do
      let(:board) { ScrumBoard.new(JSON.parse(load_test_file('full-board.json')), dummy_settings) }

      it '#done_cards' do
        expect(board.done_cards.count).to eq(3)
        expect(board.done_cards[0].name).to eq('Burndown chart')
        expect(board.done_cards[1].name).to eq('Sprint 10')
        expect(board.done_cards[2].name).to eq('(3) P3: Fill Done columns')
      end

      it '#extra_cards' do
        expect(board.extra_cards.count).to eq(1)
        expect(board.extra_cards[0].name).to eq('(8) P6: Celebrate testing board')
      end

      it '#extra_done_cards' do
        expect(board.extra_done_cards.count).to eq(0)
      end

      it '#unplanned_cards' do
        expect(board.unplanned_cards.count).to eq(2)
        expect(board.unplanned_cards[0].name).to eq('(2) Some unplanned work')
        expect(board.unplanned_cards[1].name).to eq('(1) Fix emergency')
      end

      it '#unplanned_done_cards' do
        expect(board.unplanned_done_cards.count).to eq(1)
        expect(board.unplanned_done_cards[0].name).to eq('(2) Some unplanned work')
      end

      it '#done_fast_lane_cards_count' do
        expect(board.done_fast_lane_cards_count).to eq(0)
      end

      it '#scrum_cards' do
        expect(board.scrum_cards.count).to eq(4)
        expect(board.scrum_cards[0].name).to eq('Burndown chart')
        expect(board.scrum_cards[1].name).to eq('Sprint 10')
        expect(board.scrum_cards[2].name).to eq('(3) P3: Fill Done columns')
        expect(board.scrum_cards[3].name).to eq('(2) Some unplanned work')
      end
    end

    context "full board with 'Accepted' column" do
      let(:board) { ScrumBoard.new(JSON.parse(load_test_file('full-board-with-accepted.json')), dummy_settings) }

      it '#done_cards' do
        expect(board.done_cards.count).to eq(4)
        expect(board.done_cards[0].name).to eq('Burndown chart')
        expect(board.done_cards[1].name).to eq('Sprint 10')
        expect(board.done_cards[2].name).to eq('(2) P7: Add Accepted column')
        expect(board.done_cards[3].name).to eq('(3) P3: Fill Done columns')
      end

      it '#extra_cards' do
        expect(board.extra_cards.count).to eq(1)
        expect(board.extra_cards[0].name).to eq('(8) P6: Celebrate testing board')
      end

      it '#extra_done_cards' do
        expect(board.extra_done_cards.count).to eq(0)
      end

      it '#unplanned_cards' do
        expect(board.unplanned_cards.count).to eq(2)
        expect(board.unplanned_cards[0].name).to eq('(2) Some unplanned work')
        expect(board.unplanned_cards[1].name).to eq('(1) Fix emergency')
      end

      it '#unplanned_done_cards' do
        expect(board.unplanned_done_cards.count).to eq(1)
        expect(board.unplanned_done_cards[0].name).to eq('(2) Some unplanned work')
      end

      it '#done_fast_lane_cards_count' do
        expect(board.done_fast_lane_cards_count).to eq(0)
      end

      it '#scrum_cards' do
        expect(board.scrum_cards.count).to eq(5)
        expect(board.scrum_cards[0].name).to eq('Burndown chart')
        expect(board.scrum_cards[1].name).to eq('Sprint 10')
        expect(board.scrum_cards[2].name).to eq('(2) Some unplanned work')
        expect(board.scrum_cards[3].name).to eq('(2) P7: Add Accepted column')
        expect(board.scrum_cards[4].name).to eq('(3) P3: Fill Done columns')
      end
    end
  end
end
