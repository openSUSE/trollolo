require_relative 'spec_helper'

describe Settings do

  include GivenFilesystemSpecHelpers

  context 'given config file' do
    before(:each) do
      @settings = Settings.new( File.expand_path('../../data/trollolorc', __FILE__) )
    end

    it 'is not verbose by default' do
      expect(@settings.verbose).to be false
    end

    it 'reads config file' do
      expect(@settings.developer_public_key).to eq 'mykey'
      expect(@settings.member_token).to eq 'mytoken'
    end

    context '#scrum' do
      context 'when setting is missing' do
        before do
          @settings = Settings.new( File.expand_path('../../data/trollolorc_with_board_aliases', __FILE__) )
        end
        it 'returns default settings' do
          expect(@settings.scrum['board_names']).to eq('planning' => 'Planning Board', 'sprint' => 'Sprint Board')
        end
      end

      context 'when setting does exist' do
        before do
          @settings = Settings.new( File.expand_path('../../data/trollolorc_with_custom_config', __FILE__) )
        end
        it 'returns name' do
          expect(@settings.scrum['board_names']['sprint']).to eq('Sprint B')
          expect(@settings.scrum.board_names['planning']).to eq('Planning A')
        end
      end
    end

    context '#pairing' do
      context 'when setting is missing' do
        it 'returns default settings' do
          expect(@settings.pairing['board_names']).to eq('pairing' => 'Pairing Board')
          expect(@settings.pairing['label_names']).to eq('sticky' => 'Sticky', 'interrupt' => 'Community', 'ci' => 'CI')
          expect(@settings.pairing['list_names']).to eq('day' => 'Pairing(%s)', 'tracks' => 'Tracks', 'devs' => 'Developers')
        end
      end

      context 'when setting does exist' do
        before do
          @settings = Settings.new( File.expand_path('../../data/trollolorc_with_custom_config', __FILE__) )
        end
        it 'returns name' do
          expect(@settings.pairing['board_names']['pairing']).to eq('Team Pairing Board')
          expect(@settings.pairing.labels['ci']).to eq('Pipelines')
        end
      end
    end

    context '#board_aliases' do
      context 'when aliases do not exist' do
        it 'returns an empty Hash' do
          expect(@settings.board_aliases).to eq({})
        end
      end

      context 'when mapping exists' do
        before do
          @settings = Settings.new( File.expand_path('../../data/trollolorc_with_board_aliases', __FILE__) )
        end

        it 'returns the mapping' do
          expect(@settings.board_aliases).to eq('MyTrelloBoard' => '53186e8391ef8671265eba9d')
        end
      end
    end
  end

  context 'non-existent config file' do
    use_given_filesystem

    before(:each) do
      @config_file = given_dummy_file
      @settings = Settings.new(@config_file)
    end

    it 'saves config file' do
      @settings.developer_public_key = 'mypublickey'
      @settings.member_token = 'mymembertoken'
      @settings.save_config

      expect(File.read(@config_file)).to eq "---\ndeveloper_public_key: mypublickey\nmember_token: mymembertoken\n"
    end
  end
end
