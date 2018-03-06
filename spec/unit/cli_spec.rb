require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe Cli do
  use_given_filesystem

  before(:each) do
    Cli.settings = Settings.new(
      File.expand_path('../../data/trollolorc_with_board_aliases', __FILE__))
    @cli = Cli.new
  end

  it 'fetches burndown data from board-list' do
    full_board_mock
    dir = given_directory
    @cli.options = {'board-list' => 'spec/data/board-list.yml',
                    'output' => dir}
    @cli.burndowns
    expect(File.exist?(File.join(dir, 'orange/burndown-data-01.yml'))).to be true
    expect(File.exist?(File.join(dir, 'blue/burndown-data-01.yml'))).to be true
  end

  it 'backups board' do
    expect_any_instance_of(Backup).to receive(:backup)
    @cli.options = {'board-id' => '1234'}
    @cli.backup
  end

  it 'backups board using an alias' do
    expect_any_instance_of(Backup).to receive(:backup)
    @cli.options = {'board-id' => 'MyTrelloBoard'}
    @cli.backup
  end

  it 'gets lists' do
    full_board_mock
    @cli.options = {'board-id' => '53186e8391ef8671265eba9d'}
    expected_output = <<EOT
Sprint Backlog
Doing
Done Sprint 10
Done Sprint 9
Done Sprint 8
Legend
EOT
    expect do
      @cli.get_lists
    end.to output(expected_output).to_stdout


    # Using an alias
    @cli.options = {'board-id' => 'MyTrelloBoard'}
    expect do
      @cli.get_lists
    end.to output(expected_output).to_stdout
  end

  it 'gets cards' do
    full_board_mock
    @cli.options = {'board-id' => '53186e8391ef8671265eba9d'}
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
    expect do
      @cli.get_cards
    end.to output(expected_output).to_stdout

    # Using an alias
    @cli.options = {'board-id' => 'MyTrelloBoard'}
    expect do
      @cli.get_cards
    end.to output(expected_output).to_stdout
  end

  it 'gets checklists' do
    full_board_mock
    @cli.options = {'board-id' => '53186e8391ef8671265eba9d'}
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
    expect do
      @cli.get_checklists
    end.to output(expected_output).to_stdout

    # Using an alias
    @cli.options = {'board-id' => 'MyTrelloBoard'}
    expect do
      @cli.get_checklists
    end.to output(expected_output).to_stdout
  end


  it 'shows planning backlog', vcr: 'sprint_planning_board', vcr_record: false do
    @cli.options = {'board-id' => 'QwlsiA2L'}
    expected_output = <<EOT
| Title
| (7) Outra coisa a fazer
| (3) Fazer outra coisa
| (4) Mais uma coisa
EOT
    expect do
      @cli.show_backlog
    end.to output(expected_output).to_stdout
  end

  it 'gets description' do
    skip('This tests fails after ruby-trello update')
    body = <<-EOT
{
  "id": "54ae8485221b1cc5b173e713",
  "desc": "haml"
}
EOT
    stub_request(
      :get, 'https://api.trello.com/1/cards/54ae8485221b1cc5b173e713?key=mykey&token=mytoken'
    ).with(
      headers: {
        'Accept' => '*/*; q=0.5, application/xml',
        'Accept-Encoding' => 'gzip, deflate',
        'User-Agent' => 'Ruby'
      }
    ).to_return(status: 200, body: body, headers: {})
    @cli.options = {'card-id' => '54ae8485221b1cc5b173e713'}
    expected_output = "haml\n"
    expect do
      @cli.get_description
    end.to output(expected_output).to_stdout
  end

  it 'sets description' do
    skip('This tests fails after ruby-trello update')
    expect(STDIN).to receive(:read).and_return('My description')
    stub_request(
      :put, 'https://api.trello.com/1/cards/54ae8485221b1cc5b173e713/desc?key=mykey&token=mytoken&value=My%20description'
    ).with(
      headers: {
        'Accept' => '*/*; q=0.5, application/xml',
        'Accept-Encoding' => 'gzip, deflate',
        'Content-Length' => '0',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Ruby'
      }
    ).to_return(status: 200, body: '', headers: {})
    @cli.options = {'card-id' => '54ae8485221b1cc5b173e713'}
    @cli.set_description
    expect(WebMock).to have_requested(:put, 'https://api.trello.com/1/cards/54ae8485221b1cc5b173e713/desc?key=mykey&token=mytoken&value=My%20description')
  end

  it 'sets priorities for default planning list', vcr: 'prioritize_backlog_list', vcr_record: false do
    @cli.options = {'board-id' => 'neUHHzDo'}

    expected_output = <<-EOT
set priority to 1 for "P1: (2) Document how to run cf-openstack-validator on SUSE"
set priority to 2 for "P2: Etymologie von Foo"
set priority to 3 for "P3: (3) Set up Concourse pipeline for stemcell building"
set priority to 4 for "P4: (6) Build #stemcell in containers &sort=123"
set priority to 5 for "P5: (2) Document how to run cf-openstack-validator on SUSE"
set priority to 6 for "P6: (3) Set up Concourse pipeline for os image building"
set priority to 7 for "P7: (3) Set up Concourse pipeline for stemcell building"
set priority to 8 for "P8: (6) Build stemcell in containers"
set priority to 9 for "P9: (3) Set up Concourse pipeline for BATs"
set priority to 10 for "P10: seabed"
set priority to 11 for "P11: (3) Set up Concourse pipeline for BATs"
set priority to 12 for "P12: Bike Shedding Feature"
set priority to 13 for "P13: (3) Set up Concourse pipeline for os image building"
EOT
    expect do
      @cli.set_priorities
    end.to output(expected_output).to_stdout
  end

  it 'sets priorities for specified planning list', vcr: 'prioritize_backlog_list', vcr_record: false do
    @cli.options = {'board-id' => 'neUHHzDo', 'backlog-list-name' => 'Nonexisting List'}

    expect do
      @cli.set_priorities
    end.to raise_error /'Nonexisting List' not found/
  end

  context '#board_id' do
    before do
      Cli.settings = Settings.new(
        File.expand_path('../../data/trollolorc_with_board_aliases', __FILE__))
      @cli = Cli.new
    end

    it 'returns the id when no alias exists' do
      expect(@cli.send(:board_id, '1234')).to eq('1234')
    end

    it 'return the id when an alias exists' do
      expect(@cli.send(:board_id, 'MyTrelloBoard')).to eq('53186e8391ef8671265eba9d')
    end
  end
end
