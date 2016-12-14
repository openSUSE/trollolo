require_relative "../spec_helper"

describe Scrum::Creator do
  subject { described_class.new(dummy_settings) }

  it "creates new creator" do
    expect(subject).to be
  end

  context "default" do
    it "creates boards from default config", vcr: "creator_default_config", vcr_record: false do
      expect { subject.create }.not_to raise_error
    end
    it "creates boards according to existing config", vcr: "creator_custom_config", vcr_record: false do
      expect { subject.create }.not_to raise_error
    end
  end
end
