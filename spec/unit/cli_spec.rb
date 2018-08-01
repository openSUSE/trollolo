require_relative 'spec_helper'

describe Cli do
  include GivenFilesystemSpecHelpers
  use_given_filesystem

  before(:each) do
    CliSettings.settings = Settings.new(
      File.expand_path('../../data/trollolorc_with_board_aliases', __FILE__))
    @cli = Cli.new
  end

  context '#board_id' do
    before do
      CliSettings.settings = Settings.new(
        File.expand_path('../../data/trollolorc_with_board_aliases', __FILE__))
    end

    it 'returns the id when no alias exists' do
      expect(CliSettings.send(:board_id, '1234')).to eq('1234')
    end

    it 'return the id when an alias exists' do
      expect(CliSettings.send(:board_id, 'MyTrelloBoard')).to eq('53186e8391ef8671265eba9d')
    end
  end
end
