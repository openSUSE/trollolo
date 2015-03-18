require_relative 'spec_helper'

describe "retrieve data through Trello API" do
  before(:each) do
    full_board_mock
    trello_wrapper = TrelloWrapper.new(dummy_settings)
    @board = trello_wrapper.board("53186e8391ef8671265eba9d")
  end

  describe "board" do
    it "gets id" do
      expect(@board.id).to eq("53186e8391ef8671265eba9d")
    end

    it "gets columns" do
      columns = @board.columns
      expect(columns.count).to eq(6)
      expect(columns[0].name).to eq("Sprint Backlog")
    end

    it "gets cards" do
      cards = @board.columns[0].cards
      expect(cards.count).to eq(6)
      expect(cards[0].name).to eq("Sprint 3")
    end

    it "gets checklist item counts" do
      card = @board.columns[1].cards[0]
      expect(card.tasks).to eq(2)
      expect(card.done_tasks).to eq(1)
    end

    it "gets card labels" do
      card = @board.columns[0].cards[5]
      expect(card.card_labels.count).to eq(1)
      expect(card.card_labels[0]["name"]).to eq("Under waterline")
    end

    it "gets card description" do
      card = @board.columns[2].cards[1]
      expected_desc = <<EOT
```yaml
total_days: 18
weekend_lines:
  - 1.5
  - 6.5
  - 11.5
  - 16.5
```
EOT
      expect(card.desc).to eq(expected_desc.chomp)
    end
  end
end
