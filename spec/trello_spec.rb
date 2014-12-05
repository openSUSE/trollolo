require 'spec_helper'

describe Trello do

  let(:trello) { Trello.new(board_id: "myboard", developer_public_key: "mykey", member_token: "mytoken") }

  describe "lists" do
    it "returns a list of cards" do
      stub_request(:get, "https://trello.com/1/boards/myboard/lists?key=mykey&token=mytoken").
         to_return(:status => 200, :body => load_test_file('lists.json'))
      expect(trello.lists).to be_a(Array)
    end

    it "handles a server returning garbage" do
      stub_request(:get, "https://trello.com/1/boards/myboard/lists?key=mykey&token=mytoken").
         to_return(:status => 503, :body => "nginx says no")
      expect { trello.lists }.to raise_error(Trello::ApiError)
    end

    it "handles a non-200 response" do
      stub_request(:get, "https://trello.com/1/boards/myboard/lists?key=mykey&token=mytoken").
         to_return(:status => 404, :body => "{}")
      expect { trello.lists }.to raise_error(Trello::ApiError)
    end

    it "handles a non-json response" do
      stub_request(:get, "https://trello.com/1/boards/myboard/lists?key=mykey&token=mytoken").
         to_return(:status => 200, :body => "well, garbage.")
      expect { trello.lists }.to raise_error(Trello::ApiError)
    end
  end
end
