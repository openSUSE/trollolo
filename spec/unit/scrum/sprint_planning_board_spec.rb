require_relative '../spec_helper'

describe Scrum::SprintPlanningBoard do
  subject(:planning_board) { described_class.new(dummy_settings.scrum) }

  let(:trello_board) { double('trello-board') }
  let(:waterline_card) { double('card', name: 'waterline', labels: []) }
  let(:sprint_backlog) { double('list', name: 'Backlog', cards: [waterline_card]) }

  it 'has a waterline card' do
    expect(trello_board).to receive(:lists).and_return([sprint_backlog])
    planning_board.setup(trello_board)
    expect(planning_board.waterline_card).to be
  end
end
