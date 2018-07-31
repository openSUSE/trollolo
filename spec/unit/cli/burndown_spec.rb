require_relative '../spec_helper'

describe CliBurndown do
  include GivenFilesystemSpecHelpers
  use_given_filesystem

  before(:each) do
    CliSettings.settings = Settings.new(
      File.expand_path(
        '../../../data/trollolorc_with_board_aliases',
        __FILE__
      )
    )
    @cli_burndown = CliBurndown.new
  end

  it 'fetches burndown data from board-list' do
    full_board_mock
    dir = given_directory
    @cli_burndown.options = { 'board-list' => 'spec/data/board-list.yaml',
                              'output' => dir }
    @cli_burndown.multi_update
    expect(File.exist?(File.join(dir, 'orange/burndown-data-01.yaml'))).to be true
    expect(File.exist?(File.join(dir, 'blue/burndown-data-01.yaml'))).to be true
  end
end
