require_relative "spec_helper"

describe Card do

  describe "parses name" do
    before(:each) do
      allow_any_instance_of(Card).to receive(:init_data)
      @card = Card.new(double, double)
    end

    it "extracts single digit story point value from card name" do
      allow(@card).to receive(:name).and_return("(3) P1: Refactor cards")
      expect(@card.story_points).to eq(3)
    end

    it "extracts double digit story point value from card name" do
      allow(@card).to receive(:name).and_return "(13) P1: Refactor cards"
      expect(@card.story_points).to eq(13)
    end

    it "extracts fractional story point value from card name" do
      allow(@card).to receive(:name).and_return "(0.5) P1: Refactor cards"
      expect(@card.story_points).to eq(0.5)
    end

    it "extracts priority number from card name" do
      allow(@card).to receive(:name).and_return "(0.5) P1: Refactor cards"
      expect(@card.priority).to eq(1)
    end

    it "extracts story points when value is not at beginning of card name" do
      allow(@card).to receive(:name).and_return "P01: (3) Refactor cards"
      expect(@card.story_points).to eq(3)
    end

    it "extracts priority number from card name if it is at the beginning " do
      allow(@card).to receive(:name).and_return "P01: (3) Refactor cards"
      expect(@card.priority).to eq(1)
    end
  end

  describe "updates priority" do
    before(:each) do
      @card = Card.new({"cards" => [{ "id" => "mycard" }]}, "mycard")
    end

    it "updates existing priority in title" do
      @card.name = "P01: (3) Refactor cards"
      @card.priority = 3
      expect(@card.name).to eq("P3: (3) Refactor cards")
    end

    it "adds new priority text to title" do
      @card.name = "(3) Refactor cards"
      @card.priority = 4
      expect(@card.name).to eq("P4: (3) Refactor cards")
    end

    it "updates priority after story points" do
      @card.name = "(0.5) P1: Refactor cards"
      @card.priority = 4
      expect(@card.name).to eq("(0.5) P4: Refactor cards")
    end

    it "adds priority after story points" do
      @card.name = "(0.5) P1: Refactor cards"
      @card.priority = 5
      expect(@card.name).to eq("(0.5) P5: Refactor cards")
    end
  end

  describe "#parse_yaml_from_description" do
    it "parses description only having YAML" do
      description = <<EOT
```yaml
total_days: 18
weekend_lines:
  - 1.5
  - 6.5
```
EOT
      meta = Card.parse_yaml_from_description(description)
      expect(meta["total_days"]).to eq(18)
      expect(meta["weekend_lines"]).to eq([1.5, 6.5])
    end

    it "parses description only having unmarked YAML" do
      description = <<EOT
```
total_days: 18
weekend_lines:
  - 1.5
  - 6.5
```
EOT
      meta = Card.parse_yaml_from_description(description)
      expect(meta["total_days"]).to eq(18)
      expect(meta["weekend_lines"]).to eq([1.5, 6.5])
    end

    it "parses description having YAML and text" do
      description = <<EOT
This is some text

```yaml
total_days: 18
weekend_lines:
  - 1.5
  - 6.5
```

And more text.
EOT
      meta = Card.parse_yaml_from_description(description)
      expect(meta["total_days"]).to eq(18)
      expect(meta["weekend_lines"]).to eq([1.5, 6.5])
    end
  end

  describe "gets raw JSON" do
    it "for cards" do
      @settings = dummy_settings
      full_board_mock

      trello = TrelloWrapper.new(@settings)
      board = trello.boards("53186e8391ef8671265eba9d")

      expected_json = <<EOT
{
  "id": "5319bf244cc53afd5afd991f",
  "checkItemStates": [

  ],
  "closed": false,
  "dateLastActivity": "2014-03-07T12:52:07.236Z",
  "desc": "",
  "descData": null,
  "idBoard": "53186e8391ef8671265eba9d",
  "idList": "53186e8391ef8671265eba9e",
  "idMembersVoted": [

  ],
  "idShort": 3,
  "idAttachmentCover": null,
  "manualCoverAttachment": false,
  "idLabels": [
    "5463b41e74d650d56700f16a"
  ],
  "name": "Sprint 3",
  "pos": 65535,
  "shortLink": "GRsvY3vZ",
  "badges": {
    "votes": 0,
    "viewingMemberVoted": false,
    "subscribed": false,
    "fogbugz": "",
    "checkItems": 0,
    "checkItemsChecked": 0,
    "comments": 0,
    "attachments": 0,
    "description": false,
    "due": null
  },
  "due": null,
  "email": "trello@example.com",
  "idChecklists": [

  ],
  "idMembers": [

  ],
  "labels": [
    {
      "id": "5463b41e74d650d56700f16a",
      "idBoard": "53186e8391ef8671265eba9d",
      "name": "Sticky",
      "color": "blue",
      "uses": 8
    }
  ],
  "shortUrl": "https://trello.com/c/GRsvY3vZ",
  "subscribed": false,
  "url": "https://trello.com/c/GRsvY3vZ/3-sprint-3",
  "checklists": [

  ]
}
EOT

      json = board.cards.first.as_json
      expect(json).to eq(expected_json.chomp)
    end
  end
end
