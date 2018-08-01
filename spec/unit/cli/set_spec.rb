require_relative '../spec_helper'

describe CliSet do
  include GivenFilesystemSpecHelpers
  use_given_filesystem

  before(:each) do
    CliSettings.settings = Settings.new(
      File.expand_path(
        '../../../data/trollolorc_with_board_aliases',
        __FILE__
      )
    )
    @cli_set = CliSet.new
  end

  it 'sets description' do
    expect(STDIN).to receive(:read).and_return('My description')
    stub_request(
      :put, 'https://api.trello.com/1/cards/54ae8485221b1cc5b173e713/desc?key=mykey&token=mytoken&value=My%20description'
    ).to_return(status: 200, body: '', headers: {})
    @cli_set.options = { 'card-id' => '54ae8485221b1cc5b173e713' }
    @cli_set.description
    expect(WebMock).to have_requested(:put, 'https://api.trello.com/1/cards/54ae8485221b1cc5b173e713/desc?key=mykey&token=mytoken&value=My%20description')
  end
end
