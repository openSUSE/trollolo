require "spec_helper"

describe Card do
  it "extracts single digit story point value from card name" do
    expect(Card.name_to_points("(3) P1: Refactor cards")).to eq(3)
  end

  it "extracts double digit story point value from card name" do
    expect(Card.name_to_points("(13) P1: Refactor cards")).to eq(13)
  end

  it "extracts fractional story point value from card name" do
    expect(Card.name_to_points("(0.5) P1: Refactor cards")).to eq(0.5)
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
end
