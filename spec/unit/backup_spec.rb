require_relative 'spec_helper'

describe Backup do
  include GivenFilesystemSpecHelpers

  it 'sets backup directory' do
    backup = Backup.new(dummy_settings)
    expect(backup.directory).to match File.expand_path('~/.trollolo/backup')
  end

  context 'custom backup directory' do
    use_given_filesystem(keep_files: true)

    before(:each) do
      full_board_mock
      @backup = Backup.new(dummy_settings)
      @directory = given_directory
      @backup.directory = @directory
    end

    it 'backups board' do
      @backup.backup('53186e8391ef8671265eba9d')
      backup_file = File.join(@directory, '53186e8391ef8671265eba9d', 'board.json')
      expect(File.exist?(backup_file)).to be true
      expect(File.read(backup_file)).to eq load_test_file('full-board.json').chomp
    end

    it 'lists backups' do
      @backup.backup('53186e8391ef8671265eba9d')
      expect(@backup.list).to eq ['53186e8391ef8671265eba9d']
    end

    it 'shows backup' do
      output_capturer = StringIO.new
      @backup.backup('53186e8391ef8671265eba9d')
      @backup.show('53186e8391ef8671265eba9d', output: output_capturer )
      expect(output_capturer.string).to eq(<<EOT
Trollolo Testing Board
  Sprint Backlog
    Sprint 3
    (3) P1: Fill Backlog column
      Tasks
        Add card to fill Backlog column (incomplete)
        Add card to read data from Trollolo (incomplete)
        Add card to save read data as reference data (incomplete)
        Add card under the waterline (incomplete)
    (5) P4: Read data from Trollolo
      Tasks
        Add option to Trollolo to provide the board id (incomplete)
        Call command (incomplete)
    (3) P5: Save read data as reference data
      Tasks
        Save test data (incomplete)
        Make tests work (incomplete)
    Waterline
    (8) P6: Celebrate testing board
      Tasks
        Party (incomplete)
  Doing
    (2) P2: Fill Doing column
      Tasks
        Add task to add task to Fill Doing column card (incomplete)
        Create card to Fill Doing column (complete)
      Feedback
        Ask user who requested the feature (complete)
        Ask product manager (incomplete)
    (1) Fix emergency
      Tasks
        Start (complete)
        Stop (incomplete)
  Done Sprint 10
    Burndown chart
    Sprint 10
    (3) P3: Fill Done columns
      Tasks
        Fill Done Sprint 1 (complete)
        Fill Done Sprint 2 (complete)
        Fill Done Sprint 3 (complete)
    (2) Some unplanned work
  Done Sprint 9
    Burndown chart
    Sprint 9
    (2) P1: Explain purpose
    (2) P2: Create Scrum columns
      Tasks
        Backlog (complete)
        Doing (complete)
        Multiple Done Columns (complete)
  Done Sprint 8
    Burndown chart
    Sprint 8
    (1) P1: Create Trello Testing Board
      Tasks
        Create board (complete)
        Name board (complete)
    (5) P2: Add fancy background
      Tasks
        Find image (complete)
        Download image (complete)
        Set image (complete)
        Add attribution (complete)
    (1) P4: Add legend
      Tasks
        Create Legend column (complete)
  Legend
    Purpose
    Background image
EOT
                                          )
    end
  end
end
