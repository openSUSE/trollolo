require_relative '../spec_helper'

describe Scrum::SprintCleaner do
  subject { described_class.new(dummy_settings) }

  let(:sprint_board) { Trello::Board.find('7Zar7bNm') }
  let(:planning_board) { Trello::Board.find('72tOJsGS') }

  it 'creates new sprint cleanup' do
    expect(subject).to be
  end

  it 'moves remaining cards to target board', vcr: 'sprint_cleanup', vcr_record: false do
    expect(STDOUT).to receive(:puts).exactly(13).times
    expect(subject.cleanup(sprint_board, planning_board)).to be
  end

  context 'given correct burndown-data-xx.yaml' do
    before do
      allow_any_instance_of(BurndownChart).to receive(:update)
    end

    it 'generates new burndown data', vcr: 'sprint_cleanup', vcr_record: false do
      expect do
        subject.cleanup(sprint_board, planning_board)
      end.to output(/^(New burndown data was generated automatically)/).to_stdout
    end
  end

  context 'with non-existing target list on target board' do
    before do
      subject.settings.scrum.list_names['planning_ready'] = 'Nonexisting List'
    end

    it 'throws error', vcr: 'sprint_cleanup', vcr_record: false do
      expect do
        subject.cleanup(sprint_board, planning_board)
      end.to raise_error /'Nonexisting List' not found/
    end
  end
end
