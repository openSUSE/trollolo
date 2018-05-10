require_relative '../spec_helper'

describe Scrum::Prioritizer do
  subject(:prioritizer) do
    prioritizer = described_class.new(dummy_settings)
    prioritizer.setup_boards(planning_board: planning_board)
  end

  let(:planning_board) { double('planning-board', backlog_cards: [sticky_card, card], backlog_list: double) }
  let(:sticky_card) { double('sticky-card') }
  let(:card) { double('card', name: 'Task 1') }

  before do
    allow(planning_board).to receive(:backlog_list_name).and_return('Backlog')
    allow(planning_board).to receive(:sticky?).with(card)
    allow(planning_board).to receive(:sticky?).with(sticky_card).and_return(true)
    allow(planning_board).to receive(:waterline?)
  end

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
