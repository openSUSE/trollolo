require_relative "spec_helper"
require 'pry'

describe SprintCleanup do
  it "creates new sprint cleanup" do
    sprint_cleanup = SprintCleanup.new(dummy_settings)
    expect(sprint_cleanup).to be
  end

  context "default" do
    subject { described_class.new(dummy_settings) }

    it "moves remaining cards to target board", vcr: "sprint_cleanup", vcr_rerecord: false do
      expect(subject.cleanup("GVMQz9dx", "neUHHzDo")).to be
    end
  end
end
