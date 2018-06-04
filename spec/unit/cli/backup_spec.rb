require_relative '../spec_helper'

describe CliBackup do
  use_given_filesystem

  before(:each) do
    CliSettings.settings = Settings.new(
      File.expand_path(
        '../../../data/trollolorc_with_board_aliases',
        __FILE__
      )
    )
    @cli_backup = CliBackup.new
  end

  it 'backups board' do
    expect_any_instance_of(Backup).to receive(:backup)
    @cli_backup.options = { 'board-id' => '1234' }
    @cli_backup.create
  end

  it 'backups board using an alias' do
    expect_any_instance_of(Backup).to receive(:backup)
    @cli_backup.options = { 'board-id' => 'MyTrelloBoard' }
    @cli_backup.create
  end
end
