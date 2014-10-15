require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe BurndownChart do

  before(:each) do
    @settings = dummy_settings
    @burndown_data = BurndownData.new(@settings)
    @chart = BurndownChart.new(@settings)
  end

  describe "initializer" do
    it "sets initial meta data" do
      expect(@chart.data["meta"]["sprint"]).to eq 1
      expect(@chart.data["meta"]["total_days"]).to eq 9
      expect(@chart.data["meta"]["weekend_lines"]).to eq [3.5, 7.5]
    end
  end
  
  describe "data" do
    use_given_filesystem
    
    before(:each) do
      @raw_data = [
        {
          "date" => '2014-04-23',
          "story_points" =>
          {
            "total" => 30,
            "open" => 23
          },
          "tasks" =>
          {
            "total" => 25,
            "open" => 21
          }
        },
        {
          "date" => '2014-04-24',
          "story_points" =>
          {
            "total" => 30,
            "open" => 21
          },
          "tasks" =>
          {
            "total" => 26,
            "open" => 19
          },
          "story_points_extra" =>
          {
            "done" => 3
          },
          "tasks_extra" =>
          {
            "done" => 2
          }
        }
      ]
    end

    it "creates first data entry" do
      @burndown_data.story_points.open = 16
      @burndown_data.story_points.done = 7
      @burndown_data.tasks.open = 10
      @burndown_data.tasks.done = 11

      @chart.add_data(@burndown_data,Date.parse("2014-05-30"))
      
      expect( @chart.data["days"].first["story_points"] ).to eq(
        {
          "total" => 23,
          "open" => 16
        } )
      expect( @chart.data["days"].first["tasks"] ).to eq(
        {
          "total" => 21,
          "open" => 10
        } )
    end
    
    it "returns sprint number" do
      expect(@chart.sprint).to eq 1
    end
    
    it "adds data" do
      @chart.data["days"] = @raw_data
      
      @burndown_data.story_points.open = 16
      @burndown_data.story_points.done = 7
      @burndown_data.tasks.open = 10
      @burndown_data.tasks.done = 11
      @burndown_data.extra_story_points.open = 2
      @burndown_data.extra_story_points.done = 3
      @burndown_data.extra_tasks.open = 5
      @burndown_data.extra_tasks.done = 2
      
      @chart.add_data(@burndown_data,Date.parse("2014-05-30"))
      
      expect( @chart.data["days"].count ).to eq 3
      expect( @chart.data["days"].last["date"] ).to eq ( "2014-05-30" )
      expect( @chart.data["days"].last["story_points"] ).to eq ( {
        "total" => 23,
        "open" => 16
      } )
      expect( @chart.data["days"].last["tasks"] ).to eq ( {
        "total" => 21,
        "open" => 10
      } )
      expect( @chart.data["days"].last["story_points_extra"] ).to eq ( {
        "done" => 3
      } )
      expect( @chart.data["days"].last["tasks_extra"] ).to eq ( {
        "done" => 2
      } )
    end

    it "replaces data of same day" do
      @chart.data["days"] = @raw_data
      
      @burndown_data.story_points.open = 16
      @burndown_data.story_points.done = 7
      @burndown_data.tasks.open = 10
      @burndown_data.tasks.done = 11
      
      @chart.add_data(@burndown_data,Date.parse("2014-05-30"))
      
      expect( @chart.data["days"].count ).to eq 3
      expect( @chart.data["days"].last["story_points"] ).to eq ( {
        "total" => 23,
        "open" => 16
      } )

      @burndown_data.story_points.done = 8
      @chart.add_data(@burndown_data,Date.parse("2014-05-30"))
      
      expect( @chart.data["days"].count ).to eq 3
      expect( @chart.data["days"].last["story_points"] ).to eq ( {
        "total" => 24,
        "open" => 16
      } )
    end

    it "reads data" do
      @chart.read_data given_file('burndown-data.yaml')

      expect(@chart.data["days"]).to eq @raw_data
    end
    
    it "writes data" do
      read_path = given_file('burndown-data.yaml')
      @chart.read_data(read_path)

      write_path = given_dummy_file
      @chart.write_data(write_path)

      expect(File.read(write_path)).to eq File.read(read_path)
    end

    it "doesn't write extra entries with 0 values" do
      raw_data = [
        {
          "date" => '2014-04-24',
          "story_points" =>
          {
            "total" => 30,
            "open" => 21
          },
          "tasks" =>
          {
            "total" => 26,
            "open" => 19
          },
          "story_points_extra" =>
          {
            "done" => 0
          },
          "tasks_extra" =>
          {
            "done" => 0
          }
        }
      ]
      @chart.data["days"] = raw_data
      @chart.data["meta"]["board_id"] = "1234"

      write_path = given_dummy_file
      @chart.write_data(write_path)

      expected_file_content = <<EOT
---
meta:
  board_id: '1234'
  sprint: 1
  total_days: 9
  weekend_lines:
  - 3.5
  - 7.5
days:
- date: '2014-04-24'
  story_points:
    total: 30
    open: 21
  tasks:
    total: 26
    open: 19
EOT
      expect(File.read(write_path)).to eq expected_file_content
    end

  end
  
  describe "commands" do
    use_given_filesystem(keep_files: true)

    describe "setup" do
      it "initializes new chart" do
        path = given_directory
        @chart.setup(path,"myboardid")

        expect(File.exist?(File.join(path,"burndown-data-01.yaml"))).to be true
        expect(File.exist?(File.join(path,"create_burndown"))).to be true

        chart = BurndownChart.new(@settings)
        chart.read_data(File.join(path,"burndown-data-01.yaml"))

        expect(chart.board_id).to eq "myboardid"
      end
    end
    
    describe "update" do
      it "updates chart with latest data" do
        card_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/cards\?-*/

        stub_request(:any,card_url_match).to_return(:status => 200,
          :body => load_test_file("cards.json"), :headers => {})

        list_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/lists\?-*/

        stub_request(:any,list_url_match).to_return(:status => 200,
          :body => load_test_file("lists.json"), :headers => {})

        path = given_directory_from_data("burndown_dir")

        before = BurndownChart.new(@settings)
        before.read_data(File.join(path,'burndown-data-02.yaml'))

        @chart.update(path)

        after = BurndownChart.new(@settings)
        after.read_data(File.join(path,'burndown-data-02.yaml'))

        expect(after.days.size).to eq before.days.size + 1
      end

      it "overwrites data on same date" do
        card_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/cards\?-*/

        stub_request(:any,card_url_match).to_return(:status => 200,
          :body => load_test_file("cards.json"), :headers => {})

        list_url_match = /https:\/\/trello.com\/1\/boards\/myboardid\/lists\?-*/

        stub_request(:any,list_url_match).to_return(:status => 200,
          :body => load_test_file("lists.json"), :headers => {})

        path = given_directory_from_data("burndown_dir")

        before = BurndownChart.new(@settings)
        before.read_data(File.join(path,'burndown-data-02.yaml'))

        @chart.update(path)
        @chart.update(path)

        after = BurndownChart.new(@settings)
        after.read_data(File.join(path,'burndown-data-02.yaml'))

        expect(after.days.size).to eq before.days.size + 1
      end
    end

    describe "create_next_sprint" do
      it "create new sprint file" do
        path = given_directory_from_data("burndown_dir")
        chart = BurndownChart.new(@settings)
        chart.create_next_sprint(path)

        next_sprint_file = File.join(path, "burndown-data-03.yaml")
        expect(File.exist?(next_sprint_file)).to be true

        expected_file_content = <<EOT
---
meta:
  board_id: myboardid
  sprint: 3
  total_days: 9
  weekend_lines:
  - 3.5
  - 7.5
days: []
EOT
        expect(File.read(next_sprint_file)).to eq expected_file_content
      end
    end
  end
  
end
