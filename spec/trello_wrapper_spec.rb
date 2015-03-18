require 'spec_helper'

describe TrelloWrapper do

  let!(:settings){ double('settings', developer_public_key: "mykey", member_token: "mytoken") }
  subject { described_class.new(settings) }

  before do
    stub_request(:get, "https://api.trello.com/1/boards/myboard?key=mykey&token=mytoken").
        to_return(:status => 200, :body => load_test_file("board.json"), :headers => {})
    full_board_mock
  end

  describe '.new' do
    it 'populates settings' do
      expect(subject.instance_variable_get(:@settings)).to be settings
    end

    it 'init trello configuration' do
      expect_any_instance_of(described_class).to receive(:init_trello)
      described_class.new(settings)
    end
  end

  describe '#board' do
    it 'finds board via Trello' do
      expect(Trello::Board).to receive(:find).with('myboard')
      expect_any_instance_of(ScrumBoard).to receive(:retrieve_data)
      subject.board("myboard")
    end

    it 'instantiate ScrumBoard with trello board and settings' do
      allow(Trello::Board).to receive(:find).with('myboard').and_return(:board)
      expect(ScrumBoard).to receive(:new).with(:board, subject.instance_variable_get(:@settings))
      subject.board("myboard")
    end

    it 'returns instance of a ScrumBoard' do
      expect(subject.board("myboard")).to be_instance_of(ScrumBoard)
    end

    it 'memoize board object' do
      expect(subject.board("myboard")).to be subject.board("myboard")
    end
  end
end
