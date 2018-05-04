require_relative '../spec_helper'

describe Scrum::BacklogMover do
  subject(:backlog_mover) do
    backlog_mover = described_class.new(dummy_settings)
    backlog_mover.setup_boards(
      sprint_board: sprint_board,
      planning_board: planning_board
    )
  end

  let(:sprint_board) { double('sprint-board') }
  let(:planning_board) { double('planning-board', backlog_cards: [story_card, story_card], backlog_list: double) }

  let(:story_card) { double('story-card', name: 'task', labels: [], members: []) }
  let(:waterline_card) { double('waterline-card') }
  let(:seabed_card) { double('seabed-card') }

  before(:each) do
    allow(planning_board).to receive(:waterline_card).and_return(waterline_card)
    allow(planning_board).to receive(:seabed_card).and_return(seabed_card)
    allow(planning_board).to receive(:sticky?)
  end

  it 'creates new move backlog action' do
    expect(backlog_mover).to be
  end

  it 'moves cards to sprint board' do
    expect(sprint_board).to receive(:receive).with(story_card).exactly(2).times
    expect(sprint_board).to receive(:place_seabed).with(seabed_card)
    expect(STDOUT).to receive(:puts).exactly(2).times
    backlog_mover.move
  end
end
