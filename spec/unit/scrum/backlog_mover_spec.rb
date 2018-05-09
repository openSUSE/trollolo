require_relative '../spec_helper'

describe Scrum::BacklogMover do
  subject(:backlog_mover) { described_class.new(dummy_settings) }

  let(:sprint_backlog) { double('sprint-list', name: 'Sprint Backlog', cards: []) }

  let(:planning_board) { double('trello-planning-board') }
  let(:planning_backlog) { double('planning-list', name: 'Backlog', cards: [story_card, story_card]) }
  let(:story_card) { double('old-card', name: 'task', labels: [], members: []) }

  before(:each) do
    allow(planning_board).to receive(:lists).and_return([planning_backlog])
  end

  it 'creates new move backlog' do
    expect(backlog_mover).to be
  end

  context 'when backlog is missing from sprint board' do
    let(:sprint_board) { double('trello-sprint-board', lists: []) }

    it 'fails without moving' do
      expect do
        backlog_mover.move(planning_board, sprint_board)
      end.to raise_error('sprint board is missing Sprint Backlog list')
    end
  end

  context 'when board is setup correctly' do
    let(:sprint_board) { double('trello-sprint-board', lists: [sprint_backlog]) }

    it 'moves cards to sprint board' do
      expect(story_card).to receive(:move_to_board).with(sprint_board, sprint_backlog).exactly(2).times
      expect(STDOUT).to receive(:puts).exactly(2).times
      backlog_mover.move(planning_board, sprint_board)
    end
  end
end
