require_relative '../spec_helper'

describe Scrum::SprintBoard do
  let(:settings) { dummy_settings }

  subject!(:sprint_board) { described_class.new(settings.scrum) }
  let!(:planning_board) { Scrum::SprintPlanningBoard.new(settings.scrum) }

  before(:each) do
    TrelloService.new(settings)
  end

  it 'places existing waterline card at bottom and removes from planning board', vcr: 'sprint_board', vcr_record: false do
    sprint_board.setup('NzGCbEeN')
    planning_board.setup('neUHHzDo')
    sprint_board.place_waterline(planning_board.waterline_card)
  end

  it 'moves waterline card from planning to bottom', vcr: 'sprint_board_no_waterline', vcr_record: false do
    sprint_board.setup('NzGCbEeN')
    planning_board.setup('neUHHzDo')
    sprint_board.place_waterline(planning_board.waterline_card)
  end
end
