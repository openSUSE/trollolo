require_relative "spec_helper"
require 'pry'

describe MoveBacklog do
  subject { described_class.new(real_settings) }

  it "creates new move backlog" do
    expect(subject).to be
  end

  xit "fails without moving if backlog list is missing waterline or seabed", vcr: "move_backlog_missing_waterbed", vcr_record: false do
    expect {
      subject.move("neUHHzDo", "NzGCbEeN")
    }.to raise_error("backlog list on planning board is missing waterline or seabed card")
  end

  xit "fails without moving if sprint backlog is missing from sprint board", vcr: "move_backlog_missing_backlog", vcr_record: false do
    expect {
      subject.move("neUHHzDo", "NzGCbEeN")
    }.to raise_error("sprint board is missing Sprint Backlog list")
  end

  it "moves cards to sprint board", vcr: "move_backlog", vcr_record: true do
    subject.move("neUHHzDo", "NzGCbEeN")
  end
end
