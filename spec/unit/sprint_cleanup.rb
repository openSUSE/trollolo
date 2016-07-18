require_relative "spec_helper"
require 'pry'

describe SprintCleanup do
  let(:real_settings) {
    config_path = ENV["TROLLOLO_CONFIG_PATH"] || File.expand_path("~/.trollolorc")
    Settings.new(config_path)
  }

  it "creates new sprint cleanup" do
    sprint_cleanup = SprintCleanup.new(dummy_settings)
    expect(sprint_cleanup).to be
  end

  context "default" do
    subject { described_class.new(dummy_settings) }

    it "moves remaining cards to target board", vcr: "sprint_cleanup" do
      expect(subject.cleanup("gyp75UHZ", "neUHHzDo")).to be
    end
  end
end
