require_relative '../spec_helper'

describe Scrum::SprintCleaner do
  subject(:sprint_cleaner) do
    sprint_cleaner = described_class.new(dummy_settings)
    sprint_cleaner.setup_boards(sprint_board: sprint_board, target_board: target_board)
  end

  let(:sprint_board) { double('sprint-board', backlog_list: sprint_backlog, doing_list: sprint_doing, qa_list: sprint_qa) }
  let(:sprint_backlog) { double('sprint-list', cards: [old_story_card, sticky_card]) }
  let(:sprint_doing) { double('sprint-list', cards: [old_story_card]) }
  let(:sprint_qa) { double('sprint-list', cards: [old_story_card]) }
  let(:old_story_card) { double('old-card', name: 'task', labels: [], members: []) }
  let(:sticky_card) { double('sticky-card') }
  let(:waterline_label) { double('waterline-label') }
  let(:unplanned_label) { double('unplanned-label') }

  let(:target_board) { double('trello-planning-board', lists: [planning_backlog, ready_for_estimation], id: 123) }
  let(:planning_backlog) { double('planning-list', name: 'Backlog') }
  let(:ready_for_estimation) { double('ready-list', name: 'Ready for Estimation') }

  before(:each) do
    allow(sprint_board).to receive(:sticky?)
    allow(sprint_board).to receive(:sticky?).with(sticky_card).and_return(true)
    allow(sprint_board).to receive(:find_waterline_label)
    allow(sprint_board).to receive(:find_unplanned_label)
  end

  it 'creates new sprint cleanup' do
    expect(sprint_cleaner).to be
  end

  context 'given set-last-sprint-label flag is true' do
    before do
      allow(Trello::Label).to receive(:create)
      allow_any_instance_of(Trello::Card).to receive(:add_label)
    end

    it 'moves remaining cards to target board' do
      expect(STDOUT).to receive(:puts).exactly(3).times
      expect(old_story_card).to receive(:move_to_board).with(target_board, ready_for_estimation).exactly(3).times
      expect(old_story_card).to receive(:add_label).exactly(3).times
      sprint_cleaner.cleanup(set_last_sprint_label: true)
    end
  end

  it 'moves remaining cards to target board' do
    expect(STDOUT).to receive(:puts).exactly(3).times
    expect(old_story_card).to receive(:move_to_board).with(target_board, ready_for_estimation).exactly(3).times
    sprint_cleaner.cleanup
  end

  context 'when labels are present' do
    before do
      allow(STDOUT).to receive(:puts)
      allow(sprint_board).to receive(:find_waterline_label).and_return(waterline_label)
      allow(sprint_board).to receive(:find_unplanned_label).and_return(unplanned_label)
    end

    it 'removes labels before moving cards' do
      expect(old_story_card).to receive(:remove_label).with(waterline_label).exactly(3).times
      expect(old_story_card).to receive(:remove_label).with(unplanned_label).exactly(3).times
      expect(old_story_card).to receive(:move_to_board).with(target_board, ready_for_estimation).exactly(3).times
      sprint_cleaner.cleanup
    end
  end

  context 'given correct burndown-data-xx.yaml' do
    before do
      allow_any_instance_of(BurndownChart).to receive(:update)
    end

    it 'does not generate new burndown data per default' do
      expect(old_story_card).to receive(:move_to_board).with(target_board, ready_for_estimation).exactly(3).times
      expect do
        sprint_cleaner.cleanup
      end.not_to output(/^(Update data for sprint 1)/).to_stdout
    end

    it 'generates new burndown data when run_burndown parameter is true' do
      expect(old_story_card).to receive(:move_to_board).with(target_board, ready_for_estimation).exactly(3).times
      expect do
        sprint_cleaner.cleanup(run_burndown: true)
      end.to output(/^(Update data for sprint 1)*/).to_stdout
    end
  end

  context 'with non-existing target list on target board' do
    before do
      sprint_cleaner.settings.scrum.list_names['planning_ready'] = 'Nonexisting List'
    end

    it 'throws error' do
      expect do
        sprint_cleaner.cleanup
      end.to raise_error /'Nonexisting List' not found/
    end
  end
end
