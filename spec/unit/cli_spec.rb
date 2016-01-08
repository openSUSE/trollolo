require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe Cli do
  use_given_filesystem

  before(:each) do
    Cli.settings = dummy_settings
    @cli = Cli.new
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

  it "gets lists" do
    full_board_mock
    @cli.options = {"board-id" => "53186e8391ef8671265eba9d"}
    expected_output = <<EOT
Sprint Backlog
Doing
Done Sprint 10
Done Sprint 9
Done Sprint 8
Legend
EOT
    expect {
      @cli.get_lists
    }.to output(expected_output).to_stdout
  end

  it "gets cards" do
    full_board_mock
    @cli.options = {"board-id" => "53186e8391ef8671265eba9d"}
    expected_output = <<EOT
Sprint 3
(3) P1: Fill Backlog column
(5) P4: Read data from Trollolo
(3) P5: Save read data as reference data
Waterline
(8) P6: Celebrate testing board
(2) P2: Fill Doing column
(1) Fix emergency
Burndown chart
Sprint 10
(3) P3: Fill Done columns
(2) Some unplanned work
Burndown chart
Sprint 9
(2) P1: Explain purpose
(2) P2: Create Scrum columns
Burndown chart
Sprint 8
(1) P1: Create Trello Testing Board
(5) P2: Add fancy background
(1) P4: Add legend
Purpose
Background image
EOT
    expect {
      @cli.get_cards
    }.to output(expected_output).to_stdout
  end

  it "gets checklists" do
    full_board_mock
    @cli.options = {"board-id" => "53186e8391ef8671265eba9d"}
    expected_output = <<EOT
Tasks
Tasks
Tasks
Tasks
Tasks
Feedback
Tasks
Tasks
Tasks
Tasks
Tasks
Tasks
EOT
    expect {
      @cli.get_checklists
    }.to output(expected_output).to_stdout
  end

  it "gets description" do
    body = <<-EOT
{
  "id": "54ae8485221b1cc5b173e713",
  "desc": "haml"
}
EOT
    stub_request(
      :get, "https://api.trello.com/1/cards/54ae8485221b1cc5b173e713?key=mykey&token=mytoken"
    ).with(
      :headers => {
        'Accept'=>'*/*; q=0.5, application/xml',
        'Accept-Encoding'=>'gzip, deflate',
        'User-Agent'=>'Ruby'
      }
    ).to_return(:status => 200, :body => body, :headers => {})
    @cli.options = {"card-id" => "54ae8485221b1cc5b173e713"}
    expected_output = "haml\n"
    expect {
      @cli.get_description
    }.to output(expected_output).to_stdout
  end
end
