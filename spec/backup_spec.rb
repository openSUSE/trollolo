require_relative "spec_helper"

include GivenFilesystemSpecHelpers

describe Backup do
  it "sets backup directory" do
    backup = Backup.new(dummy_settings)
    expect(backup.directory).to match File.expand_path("~/.trollolo/backup")
  end

  context "custom backup directory" do
    use_given_filesystem(keep_files: true)

    before(:each) do
      full_board_mock
      @backup = Backup.new(dummy_settings)
      @directory = given_directory
      @backup.directory = @directory
    end

    it "backups board" do
      @backup.backup("123")
      backup_file = File.join(@directory, "123", "board.json")
      expect(File.exist?(backup_file)).to be true
      expect(File.read(backup_file)).to eq load_test_file("board.json").chomp
    end

    it "lists backups" do
      @backup.backup("123")
      expect(@backup.list).to eq ["123"]
    end

    it "shows backup" do
      output_capturer = StringIO.new
      @backup.backup("123")
      @backup.show("123", output: output_capturer )
      expect(output_capturer.string).to eq(<<EOT
Trollolo Testing Board
  Sprint Backlog
    Sprint 3
    (3) P1: Fill Backlog column
    (5) P4: Read data from Trollolo
    (3) P5: Save read data as reference data
    Waterline
    (8) P6: Celebrate testing board
  Doing
    (2) P2: Fill Doing column
  Done Sprint 10
    Burndown chart
    (3) P3: Fill Done columns
  Done Sprint 9
    Burndown chart
    Sprint 2
    (2) P1: Explain purpose
    (2) P2: Create Scrum columns
  Done Sprint 8
    Burndown chart
    Sprint 1
    (1) P1: Create Trello Testing Board
    (5) P2: Add fancy background
    (1) P4: Add legend
  Legend
    Purpose
    Background image
EOT
      )
    end
  end
end
