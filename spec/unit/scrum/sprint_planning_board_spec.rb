require_relative "../spec_helper"

describe Scrum::SprintPlanningBoard do
  subject(:planning_board) { described_class.new(dummy_settings.scrum) }

  before :each do
    TrelloService.new(dummy_settings)
  end

  it "has a waterline card", vcr: "sprint_planning_board", vcr_record: false do
    planning_board.setup('neUHHzDo')
    expect(planning_board.waterline_card).to be
  end
end
