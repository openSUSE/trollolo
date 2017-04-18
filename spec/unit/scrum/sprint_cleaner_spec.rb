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

  context "with non-existing target list on target board" do
    before do
      subject.settings.scrum.list_names["planning_ready"] = "Nonexisting List"
    end

    it "throws error", vcr: "sprint_cleanup", vcr_record: false do
      expect {
        subject.cleanup("NzGCbEeN", "neUHHzDo")
      }.to raise_error /'Nonexisting List' not found/
    end
  end
end
