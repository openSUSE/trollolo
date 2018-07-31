require_relative '../spec_helper'

describe CliScrum do
  include GivenFilesystemSpecHelpers
  use_given_filesystem

  before(:each) do
    CliSettings.settings = Settings.new(
      File.expand_path(
        '../../../data/trollolorc_with_board_aliases',
        __FILE__
      )
    )
    @cli_scrum = CliScrum.new
  end

  context 'when showing backlog' do
    let(:wrapper) { double('trello-wrapper') }
    let(:scrum_board) { double('scrum-board') }
    let(:backlog_list) { double('backlog-list', cards: [card1, card2, card3]) }
    let(:card1) { double('card', name: '(7) Outra coisa a fazer') }
    let(:card2) { double('card', name: '(3) Fazer outra coisa') }
    let(:card3) { double('card', name: '(4) Mais uma coisa') }

    before do
      allow(TrelloWrapper).to receive(:new).and_return(wrapper)
    end

    it 'shows planning backlog' do
      expect(wrapper).to receive(:board).with('QwlsiA2L').and_return(scrum_board)
      expect(scrum_board).to receive(:planning_backlog_column).and_return(backlog_list)
      @cli_scrum.options = { 'board-id' => 'QwlsiA2L' }
      expected_output = <<EOT
| Title
| (7) Outra coisa a fazer
| (3) Fazer outra coisa
| (4) Mais uma coisa
EOT
      expect do
        @cli_scrum.backlog
      end.to output(expected_output).to_stdout
    end
  end

  context 'when setting card priorities' do
    let(:cards) do
      card = Struct.new(:name, :labels)
      [
        card.new('(2) Document how to run cf-openstack-validator on SUSE', []),
        card.new('Etymologie von Foo', []),
        card.new('(3) Set up Concourse pipeline for stemcell building', []),
        card.new('(6) Build #stemcell in containers &sort=123', []),
        card.new('(2) Document how to run cf-openstack-validator on SUSE', []),
        card.new('(3) Set up Concourse pipeline for os image building', []),
        card.new('(3) Set up Concourse pipeline for stemcell building', []),
        card.new('(6) Build stemcell in containers', []),
        card.new('(3) Set up Concourse pipeline for BATs', []),
        card.new('seabed', []),
        card.new('(3) Set up Concourse pipeline for BATs', []),
        card.new('Bike Shedding Feature', []),
        card.new('(3) Set up Concourse pipeline for os image building', [])
      ]
    end
    let(:backlog_list) { double('backlog-list', name: 'Backlog', cards: cards, id: 1) }
    let(:board) { double('trello-board', id: 1) }

    before do
      expect(Trello::Board).to receive(:find).with('neUHHzDo').and_return(board)
      expect(board).to receive(:lists).and_return([backlog_list])
    end

    it 'sets priorities for default planning list' do
      cards.each { |card| expect(card).to receive(:save) }
      @cli_scrum.options = { 'board-id' => 'neUHHzDo' }

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
        @cli_scrum.prioritize
      end.to output(expected_output).to_stdout
    end

    it 'sets priorities for specified planning list' do
      @cli_scrum.options = { 'board-id' => 'neUHHzDo', 'backlog-list-name' => 'Nonexisting List' }

      expect do
        @cli_scrum.prioritize
      end.to raise_error /missing the backlog list named: 'Nonexisting List'/
    end
  end
end
