require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe BurndownChart do

  before(:each) do
    @settings = dummy_settings
    @burndown_data = BurndownData.new(@settings)
    @chart = BurndownChart.new(@settings)
    full_board_mock
  end

  describe "initializer" do
    it "sets initial meta data" do
      expect(@chart.data["meta"]["sprint"]).to eq 1
      expect(@chart.data["meta"]["total_days"]).to eq 10
      expect(@chart.data["meta"]["weekend_lines"]).to eq [3.5, 8.5]
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
      @burndown_data.date_time = DateTime.parse("2014-05-30")

      @chart.add_data(@burndown_data)

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
      @burndown_data.date_time = DateTime.parse("2014-05-30")

      @chart.add_data(@burndown_data)

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
      @burndown_data.date_time = DateTime.parse("2014-05-30")

      @chart.add_data(@burndown_data)

      expect( @chart.data["days"].count ).to eq 3
      expect( @chart.data["days"].last["story_points"] ).to eq ( {
        "total" => 23,
        "open" => 16
      } )

      @burndown_data.story_points.done = 8
      @chart.add_data(@burndown_data)

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
  total_days: 10
  weekend_lines:
  - 3.5
  - 8.5
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
        @chart.setup(path,"53186e8391ef8671265eba9d")

        expect(File.exist?(File.join(path,"burndown-data-01.yaml"))).to be true

        chart = BurndownChart.new(@settings)
        chart.read_data(File.join(path,"burndown-data-01.yaml"))

        expect(chart.board_id).to eq "53186e8391ef8671265eba9d"
      end
    end

    describe "last_sprint" do
      it "gets the last sprint based on the burndown files" do
        path = given_directory_from_data("burndown_dir")
        expect(@chart.last_sprint(path)).to eq(2)
      end
    end

    describe "load_last_sprint" do
      let(:path) { given_directory_from_data("burndown_dir") }
      it "loads the burndown form the 2nd sprint into data" do
        @chart.load_last_sprint(path)
        expect(@chart.data).to eq({"meta"=>
                                   {"board_id"=>"53186e8391ef8671265eba9d",
                                    "sprint"=>2,
                                    "total_days"=>9,
                                    "weekend_lines"=>[3.5, 7.5]},
                                   "days"=>[]})
      end

      it "returns the path of the last sprint" do
        expect(@chart.load_last_sprint(path)).to eq(File.join(path,"burndown-data-02.yaml"))
      end
    end

    describe "update" do

      let(:path) { given_directory_from_data("burndown_dir") }
      let(:options) { {'output' => path} }
      let(:before) { BurndownChart.new(@settings) }
      let(:after) { BurndownChart.new(@settings) }

      it "updates chart with latest data" do
        before.read_data(File.join(path,'burndown-data-02.yaml'))
        @chart.update(options)
        after.read_data(File.join(path,'burndown-data-02.yaml'))
        expect(after.days.size).to eq before.days.size + 1
      end

      it "overwrites data on same date" do
        before.read_data(File.join(path,'burndown-data-02.yaml'))
        @chart.update(options)
        @chart.update(options)
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
  board_id: 53186e8391ef8671265eba9d
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

  describe "reads meta data from the board" do

    use_given_filesystem

    it "merges meta data from board if present" do
      chart = BurndownChart.new(@settings)
      chart.read_data(given_file("burndown-data-10.yaml"))

      expect(chart.data["meta"]["weekend_lines"]).to eq([3.5, 8.5])

      burndown = BurndownData.new(@settings)
      burndown.board_id = "53186e8391ef8671265eba9d"
      burndown.fetch

      chart.merge_meta_data_from_board(burndown)

      expect(chart.data["meta"]["weekend_lines"]).to eq([1.5, 6.5, 11.5, 16.5])
    end
  end

  describe '.plot' do

    it 'sends joined parsed options to python script' do
      allow(described_class).to receive(:process_options).and_return(%w{ --test 1 --no-blah })
      allow(described_class).to receive(:plot_helper).and_return('mescript')
      expect(described_class).to receive(:system).with('python mescript 42 --test 1 --no-blah')
      described_class.plot(42, {foo: 1, bar: 2})
    end

  end

  describe '.plot_helper' do

    it 'expands path to burndown generator' do
      expect(described_class.plot_helper).to include('scripts/create_burndown.py')
    end

  end

  describe '.process_options' do

    it 'builds an array of switches for burndown chart based on input hash' do
      test_hash = { 'no-tasks' => true }
      expect(described_class.send(:process_options, test_hash)).to eq %w{ --no-tasks }
      test_hash = { 'with-fast-lane' => true }
      expect(described_class.send(:process_options, test_hash)).to eq %w{ --with-fast-lane }
      test_hash = { 'output' => 'fanagoro' }
      expect(described_class.send(:process_options, test_hash)).to eq [ '--output fanagoro' ]
      test_hash = {}
      expect(described_class.send(:process_options, test_hash)).to eq [ ]
      test_hash = {
        'no-tasks'       => true,
        'with-fast-lane' => true,
        'output'         => 'fanagoro',
        'verbose'        => true
      }
      expect(described_class.send(:process_options, test_hash)).to eq ['--no-tasks', '--with-fast-lane', '--output fanagoro', '--verbose']
    end

  end
end
