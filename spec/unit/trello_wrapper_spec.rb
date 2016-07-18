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
      subject.boards("myboard")
    end

    it 'instantiate ScrumBoard with trello board and settings' do
      expect(ScrumBoard).to receive(:new).with(:board, subject.instance_variable_get(:@settings))
      subject.boards("myboard")
    end

    it 'returns instance of a ScrumBoard' do
      expect(subject.boards("myboard")).to be_instance_of(ScrumBoard)
    end

    it 'memoize board object' do
      expect(subject.boards("myboard")).to be subject.boards("myboard")
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
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'188', 'Content-Type'=>'multipart/form-data; boundary=470924', 'User-Agent'=>'Ruby'}).
            to_return(:status => 200, :body => "", :headers => {})

      path = given_file("attachment-data")

      subject.add_attachment("123", path)
    end
  end

  describe "#make_cover" do
    let(:card_id) { "c133a484cff21c7a33ff031f" }
    let(:image_id) { "484cff21c7a33ff031f997a" }
    let(:image_name) { "passed.jpg" }
    let(:client) { double }
    let(:card_attachments_body) { <<-EOF
      [
        {
          "id":"78d86ae7f25c748559b37ca",
          "name":"failed.jpg"
        },
        {
          "id":"484cff21c7a33ff031f997a",
          "name":"passed.jpg"
        }
      ]
EOF
    }

    before(:each) do
      stub_request(:get, "https://api.trello.com/1/cards/#{card_id}/attachments?fields=name&key=mykey&token=mytoken").
        with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => card_attachments_body, :headers => {})
      stub_request(:put, "https://api.trello.com/1/cards/#{card_id}/idAttachmentCover?key=mykey&token=mytoken&value=#{image_id}").
                 with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'0', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'})
    end

    it "make the attachment with the file name passed.jpg the cover" do
     subject.make_cover(card_id, image_name)
     expect(WebMock).to have_requested(:put, "https://api.trello.com/1/cards/#{card_id}/idAttachmentCover?key=mykey&token=mytoken&value=#{image_id}")
    end

    it "shows an error if the file was not found in the attachment list" do
      expect { subject.make_cover(card_id, "non_existing_file.jpg") }.to raise_error(/non_existing_file.jpg/)
    end
  end
end
