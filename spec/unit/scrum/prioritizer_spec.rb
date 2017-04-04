require_relative "../spec_helper"

describe Scrum::Prioritizer do
  subject { described_class.new(dummy_settings) }

  it "creates new prioritizer" do
    expect(subject).to be
  end

  context "default" do
    it "raises an exception if board is not found", vcr: "prioritize_no_backlog_list", vcr_record: false do
      expect { subject.prioritize("xxxxx123") }.to raise_error(Trello::Error)
    end

    it "raises an exception if list is not on board", vcr: "prioritize_no_backlog_list", vcr_record: false do
      expect { subject.prioritize("neUHHzDo") }.to raise_error("list named 'Backlog' not found on board")
    end

    it "adds priority text to card titles", vcr: "prioritize_backlog_list", vcr_record: false do
      expect(STDOUT).to receive(:puts).exactly(13).times
      expect { subject.prioritize("neUHHzDo") }.not_to raise_error
    end
  end

  context "specifying backlog list as argument" do
    before do
      subject.settings.scrum.list_names["planning_backlog"] = "Nonexisting List"
    end

    it "finds backlog list", vcr: "prioritize_backlog_list", vcr_record: false do
      expect(STDOUT).to receive(:puts).exactly(13).times
      expect {
        subject.prioritize("neUHHzDo", "Backlog")
      }.not_to raise_error
    end

    it "throws error when default list does not exist", vcr: "prioritize_backlog_list", vcr_record: false  do
      expect { subject.prioritize("neUHHzDo") }.to raise_error("list named 'Nonexisting List' not found on board")
    end

    it "throws error when specified list does not exist", vcr: "prioritize_backlog_list", vcr_record: false  do
      expect { subject.prioritize("neUHHzDo", "My Backlog") }.to raise_error("list named 'My Backlog' not found on board")
    end
  end
end
