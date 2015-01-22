require 'spec_helper'

describe TrelloWrapper do

  let!(:settings){ double('settings', developer_public_key: "mykey", member_token: "mytoken") }
  subject { described_class.new("myboard", settings) }

  before do
    stub_request(:get, "https://api.trello.com/1/boards/myboard?key=mykey&token=mytoken").
        to_return(:status => 200, :body => load_test_file("board.json"), :headers => {})
  end

  describe '.new' do

    it 'populates board_id' do
      expect(subject.instance_variable_get(:@board_id)).to eq 'myboard'
    end

    it 'populates settings' do
      expect(subject.instance_variable_get(:@settings)).to be settings
    end

    it 'init trello configuration' do
      expect_any_instance_of(described_class).to receive(:init_trello)
      described_class.new("myboard", settings)
    end

  end

  describe '#board' do

    it 'finds board via Trello' do
      expect(Trello::Board).to receive(:find).with('myboard')
      subject.board
    end

    it 'instantiate ScrumBoard with trello board and settings' do
      allow(Trello::Board).to receive(:find).with('myboard').and_return(:board)
      expect(ScrumBoard).to receive(:new).with(:board, subject.instance_variable_get(:@settings))
      subject.board
    end

    it 'returns instance of a ScrumBoard' do
      expect(subject.board).to be_instance_of(ScrumBoard)
    end

    it 'memoize board object' do
      expect(subject.board).to be subject.board
    end

  end

end
