require_relative '../spec_helper'

describe Scrum::SprintCleaner do
  subject(:sprint_cleaner) { described_class.new(dummy_settings) }

  let(:sprint_board) { double('trello-sprint-board') }
  let(:planning_board) { double('trello-planning-board') }

  let(:sprint_backlog) { double('sprint-list', name: 'Sprint Backlog', cards: [old_story_card]) }
  let(:sprint_doing) { double('sprint-list', name: 'Doing', cards: [old_story_card]) }
  let(:sprint_qa) { double('sprint-list', name: 'QA', cards: [old_story_card]) }
  let(:old_story_card) { double('old-card', name: 'task', labels: [], members: []) }

  let(:planning_backlog) { double('planning-list', name: 'Backlog', cards: []) }
  let(:ready_for_estimation) { double('ready-list', name: 'Ready for Estimation', cards: [story_card]) }
  let(:story_card) { double('card', name: 'task', labels: []) }

  before(:each) do
    allow(sprint_board).to receive(:lists).and_return([sprint_backlog, sprint_doing, sprint_qa])
    allow(planning_board).to receive(:lists).and_return([planning_backlog, ready_for_estimation])
  end

  it 'creates new sprint cleanup' do
    expect(sprint_cleaner).to be
  end

  it 'moves remaining cards to target board' do
    expect(STDOUT).to receive(:puts).exactly(4).times
    expect(old_story_card).to receive(:move_to_board).with(planning_board, ready_for_estimation).exactly(3).times
    expect(sprint_cleaner.cleanup(sprint_board, planning_board)).to be
  end

  context 'given correct burndown-data-xx.yaml' do
    before do
      allow_any_instance_of(BurndownChart).to receive(:update)
    end

    it 'generates new burndown data' do
      expect(old_story_card).to receive(:move_to_board).with(planning_board, ready_for_estimation).exactly(3).times
      expect do
        sprint_cleaner.cleanup(sprint_board, planning_board)
      end.to output(/^(New burndown data was generated automatically)/).to_stdout
    end
  end

  context 'with non-existing target list on target board' do
    before do
      sprint_cleaner.settings.scrum.list_names['planning_ready'] = 'Nonexisting List'
    end

    it 'throws error' do
      expect do
        sprint_cleaner.cleanup(sprint_board, planning_board)
      end.to raise_error /'Nonexisting List' not found/
    end
  end
end
