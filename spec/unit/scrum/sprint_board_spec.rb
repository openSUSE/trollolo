require_relative '../spec_helper'

describe Scrum::SprintBoard do
  let(:settings) { dummy_settings }

  subject!(:sprint_board) { described_class.new(settings.scrum) }
  let!(:planning_board) { Scrum::SprintPlanningBoard.new(settings.scrum) }

  let(:trello_sprint_board) { double('trello-sprint-board', id: 123) }
  let(:trello_planning_board) { double('trello-planning-board', id: 345) }
  let(:planning_backlog) { double('list', name: 'Backlog', cards: [planning_waterline_card], id: 234) }
  let(:planning_waterline_card) { double('card', name: 'planning-waterline', labels: []) }
  let(:waterline_card) { double('card', name: 'waterline', labels: []) }

  before(:each) do
    allow(trello_sprint_board).to receive(:lists).and_return([sprint_backlog])
    allow(trello_planning_board).to receive(:lists).and_return([planning_backlog])
  end

  context 'when waterline card exists on sprint board' do
    let(:sprint_backlog) { double('list', name: 'Sprint Backlog', cards: [waterline_card], id: 456) }

    it 'places existing waterline card at bottom and removes from planning board' do
      sprint_board.setup(trello_sprint_board)
      planning_board.setup(trello_planning_board)

      expect(waterline_card).to receive(:pos=).with('bottom')
      expect(waterline_card).to receive(:save)
      sprint_board.place_waterline(planning_board.waterline_card)
    end
  end

  context 'when waterline card is missing from sprint board' do
    let(:sprint_backlog) { double('list', name: 'Sprint Backlog', cards: [], id: 456) }

    it 'moves waterline card from planning to bottom' do
      sprint_board.setup(trello_sprint_board)
      planning_board.setup(trello_planning_board)

      expect(planning_waterline_card).to receive(:move_to_board).with(trello_sprint_board, sprint_backlog)
      sprint_board.place_waterline(planning_board.waterline_card)
    end
  end
end
