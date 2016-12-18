require_relative "../spec_helper"

describe Scrum::SprintCleaner do
  subject { described_class.new(dummy_settings) }

  it "creates new sprint cleanup" do
    expect(subject).to be
  end

  it "moves remaining cards to target board", vcr: "sprint_cleanup", vcr_record: false do
    expect(STDOUT).to receive(:puts).exactly(12).times
    expect(subject.cleanup("NzGCbEeN", "neUHHzDo")).to be
  end
end
