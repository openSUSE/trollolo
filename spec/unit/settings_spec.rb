require_relative 'spec_helper'

describe Settings do

  include GivenFilesystemSpecHelpers
  
  context "given config file" do
    before(:each) do
      @settings = Settings.new( File.expand_path('../../data/trollolorc',__FILE__) )
    end
    
    it "is not verbose by default" do
      expect(@settings.verbose).to be false
    end

    it "reads config file" do
      expect(@settings.developer_public_key).to eq "mykey"
      expect(@settings.member_token).to eq "mytoken"
    end

    context "#board_aliases" do
      context "when aliases do not exist" do
        it "returns an empty Hash" do
          expect(@settings.board_aliases).to eq({})
        end
      end

      context "when mapping exists" do
        before do
          @settings = Settings.new( File.expand_path('../../data/trollolorc_with_board_aliases',__FILE__) )
        end

        it "returns the mapping" do
          expect(@settings.board_aliases).to eq({"MyTrelloBoard" => "53186e8391ef8671265eba9d"})
        end
      end
    end
  end
  
  context "non-existent config file" do
    use_given_filesystem
  
    before(:each) do
      @config_file = given_dummy_file
      @settings = Settings.new(@config_file)
    end

    it "saves config file" do
      @settings.developer_public_key = "mypublickey"
      @settings.member_token = "mymembertoken"
      @settings.save_config
      
      expect(File.read(@config_file)).to eq "---\ndeveloper_public_key: mypublickey\nmember_token: mymembertoken\n"
    end
  end

end
