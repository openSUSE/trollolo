require_relative '../spec_helper'

describe Scrum::BacklogMover do
  subject { described_class.new(dummy_settings) }

  it 'creates new move backlog' do
    expect(subject).to be
  end

  it 'fails without moving if sprint backlog is missing from sprint board', vcr: 'move_backlog_missing_backlog', vcr_record: false do
    expect do
      subject.move('neUHHzDo', 'NzGCbEeN')
    end.to raise_error('sprint board is missing Sprint Backlog list')
  end

  it 'moves cards to sprint board', vcr: 'move_backlog', vcr_record: false do
    expect(STDOUT).to receive(:puts).exactly(11).times
    subject.move('neUHHzDo', 'NzGCbEeN')
  end
end
