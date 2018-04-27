require_relative '../spec_helper'

describe Pairing::Creator do
  subject { described_class.new(settings) }

  let(:settings) { dummy_settings }
  let(:custom_subject) do
    custom_settings = settings
    custom_settings.pairing.board_names['pairing'] = 'Pairing Brett'
    described_class.new(settings)
  end

  it 'creates new creator' do
    expect(subject).to be
  end

  context 'default' do
    it 'creates boards from default config', vcr: 'pairing_creator_default_config', vcr_record: false do
      expect { subject.create }.not_to raise_error
    end
    it 'creates boards according to existing config', vcr: 'pairing_creator_custom_config', vcr_record: false do
      expect { custom_subject.create }.not_to raise_error
    end
  end
end
