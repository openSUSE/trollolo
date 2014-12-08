require "spec_helper"

describe Card do
  it "extracts single digit story point value from card name" do
    expect(Card.name_to_points("(3) P1: Refactor cards")).to eq(3)
  end

  it "extracts double digit story point value from card name" do
    expect(Card.name_to_points("(13) P1: Refactor cards")).to eq(13)
  end

  it "extracts fractional story point value from card name" do
    expect(Card.name_to_points("(0.5) P1: Refactor cards")).to eq(0.5)
  end
end
