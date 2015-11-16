require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe TrelloWrapper do

  let!(:settings){ double('settings', developer_public_key: "mykey", member_token: "mytoken") }
  subject { described_class.new(settings) }

  before do
    stub_request(:get, "https://api.trello.com/1/boards/myboard?cards=open&key=mykey&lists=open&token=mytoken").
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
    before(:each) do
      expect(subject).to receive(:retrieve_board_data).with('myboard').and_return(:board)
    end

    it 'finds board via Trello' do
      subject.board("myboard")
    end

    it 'instantiate ScrumBoard with trello board and settings' do
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

  describe '#add_attachment' do
    use_given_filesystem

    it "uploads attachment" do
      srand(1) # Make sure multipart boundary is always the same

      card_body = <<EOT
{
  "name": "mycard",
  "id": "123"
}
EOT

      stub_request(:get, "https://api.trello.com/1/cards/123?key=mykey&token=mytoken").
        with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => card_body, :headers => {})

      stub_request(:post, "https://api.trello.com/1/cards/123/attachments?key=mykey&token=mytoken").
          with(:body => "--470924\r\nContent-Disposition: form-data; name=\"file\"; filename=\"attachment-data\"\r\nContent-Type: text/plain\r\n\r\nabc\n\r\n--470924\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n\r\n--470924--\r\n",
               :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'188', 'Content-Type'=>'multipart/form-data; boundary=470924', 'User-Agent'=>'Ruby'}).
            to_return(:status => 200, :body => "", :headers => {})

      path = given_file("attachment-data")

      subject.add_attachment("123", path)
    end
  end
end
