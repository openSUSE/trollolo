require_relative "../spec_helper"

describe Scrum::PriorityName do
  let(:priority_name) { Scrum::PriorityName }

  describe "parses name" do
    it "extracts priority number from card name" do
      expect(priority_name.priority("(0.5) P1: Refactor cards")).to eq(1)
    end

    it "extracts priority number from card name if it is at the beginning " do
      expect(priority_name.priority("P01: (3) Refactor cards")).to eq(1)
    end
  end

  describe "updates priority" do
    it "updates existing priority in title" do
      expect(
        priority_name.build("P01: (3) Refactor cards", 3)
      ).to eq("P3: (3) Refactor cards")
    end

    it "adds new priority text to title" do
      expect(
        priority_name.build("(3) Refactor cards", 4)
      ).to eq("P4: (3) Refactor cards")
    end

    it "updates priority after story points" do
      expect(
        priority_name.build("(0.5) P1: Refactor cards", 4)
      ).to eq("(0.5) P4: Refactor cards")
    end
  end
end
