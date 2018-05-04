require_relative '../spec_helper'

describe Scrum::CardTypeDetection do
  subject { dummy_class.new }

  let(:dummy_class) { Class.new { include Scrum::CardTypeDetection } }
  let(:waterline_card) { instance_double('Card', name: 'waterline') }
  let(:upcase_waterline_card) { instance_double('Card', name: 'Waterline') }
  let(:fancy_waterline_card) { instance_double('Card', name: '~~~ WaTeR lInE ~~~') }
  let(:seabed_card) { instance_double('Card', name: 'seabed') }
  let(:fancy_seabed_card) { instance_double('Card', name: '!-! Sea Bed !-!') }

  it 'recognizes waterline string' do
    expect(subject.waterline?(waterline_card)).to be_truthy
  end

  it 'refuses non waterline name' do
    expect(subject.waterline?(seabed_card)).to be_falsy
  end

  it 'recognizes upcase spellings of waterline' do
    expect(subject.waterline?(upcase_waterline_card)).to be_truthy
  end

  it 'recognizes fancy spellings of waterline' do
    expect(subject.waterline?(fancy_waterline_card)).to be_truthy
  end

  it 'recognizes fancy spellings of seabed' do
    expect(subject.seabed?(fancy_seabed_card)).to be_truthy
  end

  it 'refuses non seabed name' do
    expect(subject.seabed?(waterline_card)).to be_falsy
  end
end
