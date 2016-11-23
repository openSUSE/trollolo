require_relative "../spec_helper"

describe Scrum::Prioritizer do
  subject { described_class.new(dummy_settings) }

  it "creates new prioritizer" do
    expect(subject).to be
  end

  context "default" do
    before(:each) do
      full_board_mock
    end

    it "raises an exception if list is not on board" do
      expect {
        subject.prioritize("53186e8391ef8671265eba9d", "Backlog")
      }.to raise_error("list not found on board")
    end

    it "raises an exception if list is not on board" do
			RSpec::Expectations.configuration.on_potential_false_positives = :nothing
      expect {
        subject.prioritize("53186e8391ef8671265eba9d", "Sprint Backlog")
      }.not_to raise_error("list not found on board")
    end

    it "adds priority text to card titles" do
      [
        "5319bf244cc53afd5afd991f/name?key=mykey&token=mytoken&value=P1:%20Sprint%203",
        "5319c16d9d04708d450d65f1/name?key=mykey&token=mytoken&value=(3)%20P2:%20Fill%20Backlog%20column",
        "5319c57ff6be845f428aa7a3/name?key=mykey&token=mytoken&value=(5)%20P3:%20Read%20data%20from%20Trollolo",
        "5319c5961e530fd26f83999d/name?key=mykey&token=mytoken&value=(3)%20P4:%20Save%20read%20data%20as%20reference%20data",
        "5319c5a8743488047e13fcbc/name?key=mykey&token=mytoken&value=(8)%20P5:%20Celebrate%20testing%20board",
      ].each { |value|
        stub_request(:put, "https://api.trello.com/1/cards/#{value}")
      }

      expect(STDOUT).to receive(:puts).exactly(5).times
      expect {
        subject.prioritize("53186e8391ef8671265eba9d", "Sprint Backlog")
      }.not_to raise_error
    end
  end
end
