require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe Cli do

  use_given_filesystem

  before(:each) do
    Cli.settings = dummy_settings
    @cli = Cli.new
    
    allow(STDOUT).to receive(:puts)
  end
  
  it "fetches burndown data" do
    expect_any_instance_of(BurndownData).to receive(:fetch)
    
    @cli.fetch_burndown_data
  end
  
  it "fetches burndown data from board-list" do
    full_board_mock
    dir = given_directory
    @cli.options = {"board-list" => "spec/data/board-list.yaml",
                    "output" => dir}
    @cli.burndowns
    expect(File.exist?(File.join(dir,"orange/burndown-data-01.yaml")))
    expect(File.exist?(File.join(dir,"blue/burndown-data-01.yaml")))
  end

  it "backups board" do
    expect_any_instance_of(Backup).to receive(:backup)
    @cli.options = {"board-id" => "1234"}
    @cli.backup
  end

end
