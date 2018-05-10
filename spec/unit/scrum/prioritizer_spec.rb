require_relative '../spec_helper'

describe Scrum::Prioritizer do
  subject(:prioritizer) do
    prioritizer = described_class.new(dummy_settings)
    prioritizer.setup_boards(
      planning_board: boards.planning_board(trello_planning_board)
    )
  end

  let(:boards) { Scrum::Boards.new(dummy_settings.scrum) }
  let(:trello_planning_board) { double(lists: lists) }
  let(:lists) { [list] }
  let(:list) { double('list', name: 'Backlog', cards: [sticky_card, card]) }
  let(:sticky_card) { double('sticky-card', labels: [double(name: 'Sticky')]) }
  let(:card) { double('card', name: 'Task 1', labels: []) }

  it 'creates new prioritizer' do
    expect(prioritizer).to be
  end

  it 'adds priority text to card titles' do
    expect(card).to receive(:name=).with('P1: Task 1')
    expect(card).to receive(:save)
    expect(STDOUT).to receive(:puts).exactly(1).times
    expect { prioritizer.prioritize }.not_to raise_error
  end
end
