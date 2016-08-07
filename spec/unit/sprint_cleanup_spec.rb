require_relative "spec_helper"
require 'pry'

describe SprintCleanup do
  subject { described_class.new(dummy_settings) }

  it "creates new sprint cleanup" do
    expect(subject).to be
  end

  it "moves remaining cards to target board", vcr: "sprint_cleanup", vcr_record: false do
    expect(STDOUT).to receive(:puts).exactly(5).times
    expect(subject.cleanup("GVMQz9dx", "neUHHzDo")).to be
  end
end
