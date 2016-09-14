require_relative "../spec_helper"

describe Scrum::CardTypeDetection do
  let(:dummy_class) { Class.new { include Scrum::CardTypeDetection } }
  subject { dummy_class.new }
  let(:waterline_card) { instance_double("Card", name: 'waterline') }
  let(:upcase_waterline_card) { instance_double("Card", name: 'Waterline') }
  let(:fancy_waterline_card) { instance_double("Card", name: '~~~ WaTeR lInE ~~~') }
  let(:seabed_card) { instance_double("Card", name: 'seabed') }
  let(:fancy_seabed_card) { instance_double("Card", name: '!-! Sea Bed !-!') }

  it "recognizes waterline string" do
    expect(subject.is_waterline?(waterline_card)).to be_truthy
  end

  it "refuses non waterline name" do
    expect(subject.is_waterline?(seabed_card)).to be_falsy
  end

  it "recognizes upcase spellings of waterline" do
    expect(subject.is_waterline?(upcase_waterline_card)).to be_truthy
  end

  it "recognizes fancy spellings of waterline" do
    expect(subject.is_waterline?(fancy_waterline_card)).to be_truthy
  end

  it "recognizes fancy spellings of seabed" do
    expect(subject.is_seabed?(fancy_seabed_card)).to be_truthy
  end

  it "refuses non seabed name" do
    expect(subject.is_seabed?(waterline_card)).to be_falsy
  end
end
