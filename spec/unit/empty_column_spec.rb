require_relative 'spec_helper'

describe EmptyColumn do
  [:committed_cards, :extra_cards, :unplanned_cards, :cards, :fast_lane_cards].each do |cards_method|
    it "##{cards_method}" do
      expect(subject.send(cards_method)).to eq([])
    end
  end
end
