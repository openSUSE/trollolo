require_relative '../spec_helper'

describe Pairing::PairingBoard do
  let(:settings) { dummy_settings }
  recording = false

  subject!(:sprint_board) { described_class.new(settings.pairing) }
  let!(:pairing_board) { Pairing::PairingBoard.new(settings.pairing) }

  before(:each) do
    TrelloService.new(settings)
    pairing_board.setup('UAUzYfm8')
  end

  it 'creates a new list with pairs assigned to each card', vcr: 'pairing_board_pair', vcr_record: recording do
    pairing_board.pair
    expect(pairing_board.board.lists.find { |l| l.name == 'Pairing(23.05.2018)' }).to be_truthy
  end

  it 'returns devs', vcr: 'pairing_board_pair', vcr_record: recording do
    expect(pairing_board.devs.count).to equal(2)
  end

  it 'returns tracks', vcr: 'pairing_board_pair', vcr_record: recording do
    expect(pairing_board.tracks.count).to equal(3)
  end
end
