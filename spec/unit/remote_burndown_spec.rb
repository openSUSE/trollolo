require_relative 'spec_helper'

describe RemoteBurndown do
  include GivenFilesystemSpecHelpers

  let(:burndown_data) do
    burndown_data = BurndownData.new(dummy_settings)
    burndown_data.story_points.open = 16
    burndown_data.story_points.done = 7
    burndown_data.tasks.open = 10
    burndown_data.tasks.done = 11
    burndown_data.date_time = DateTime.parse('2014-05-30')
    burndown_data
  end

  before(:each) do
    full_board_mock

    board_id = 'P4kJA4bE'
    burndown_card_id = '57ff6f33a8d18219092685f4'
    description = "```yaml\n---\nmeta:\n  board_id: P4kJA4bE\n  sprint: 1\n  total_days: 10\n  weekend_lines:\n  - 3.5\n  - 8.5\ndays: []\n```"
    sample_url = "https://api.trello.com/1/cards/#{burndown_card_id}/desc?key=mykey&token=mytoken&value=#{description}"
    stub_request(:put, sample_url).to_return(status: 200)

    @settings = dummy_settings
    @chart = RemoteBurndown.new(@settings, board_id, true)
    allow(BurndownData).to receive(:new).and_return(burndown_data)
  end

  describe 'initializer' do
    it 'sets initial meta data' do
      expect(@chart.data['meta']['sprint']).to eq 1
      expect(@chart.data['meta']['total_days']).to eq 10
      expect(@chart.data['meta']['weekend_lines']).to eq [3.5, 8.5]
    end
  end

  it 'writes yaml block to burndown card' do
    response = @chart.write_data
    expect(response.code).to eq 200
  end

  it 'reads yaml block from burndown card' do
    data = @chart.read_data
    expect(@chart.data['meta']['board_id']).to eq data['meta']['board_id']
  end

  it 'updates data' do
    expect { @chart.update_data(burndown_data) }.to change { @chart.data['days'].length }.from(0).to(1)
  end
end
