require_relative '../spec_helper'

describe Scrum::SprintCleaner do
  subject { described_class.new(dummy_settings) }

  it 'creates new sprint cleanup' do
    expect(subject).to be
  end

  it 'moves remaining cards to target board', vcr: 'sprint_cleanup', vcr_record: false do
    expect(STDOUT).to receive(:puts).exactly(13).times
    expect(subject.cleanup('7Zar7bNm', '72tOJsGS')).to be
  end

  context 'given correct burndown-data-xx.yml' do
    before do
      allow_any_instance_of(BurndownChart).to receive(:update)
    end

    it 'generates new burndown data', vcr: 'sprint_cleanup', vcr_record: false do
      expect do
        subject.cleanup('7Zar7bNm', '72tOJsGS')
      end.to output(/^(New burndown data was generated automatically)/).to_stdout
    end
  end

  context 'with non-existing target list on target board' do
    before do
      subject.settings.scrum.list_names['planning_ready'] = 'Nonexisting List'
    end

    it 'throws error', vcr: 'sprint_cleanup', vcr_record: false do
      expect do
        subject.cleanup('7Zar7bNm', '72tOJsGS')
      end.to raise_error /'Nonexisting List' not found/
    end
  end
end
