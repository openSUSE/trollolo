require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe BurndownChart do

  subject { BurndownChart.new(dummy_settings) }

  let(:burndown_data) do
    burndown_data = BurndownData.new(dummy_settings)
    burndown_data.story_points.open = 16
    burndown_data.story_points.done = 7
    burndown_data.tasks.open = 10
    burndown_data.tasks.done = 11
    burndown_data.date_time = DateTime.parse('2014-05-30')
    burndown_data
  end

  before(:each) do
    @settings = dummy_settings
    @burndown_data = BurndownData.new(@settings)
    @chart = BurndownChart.new(@settings)
    allow(BurndownData).to receive(:new).and_return(burndown_data)
    full_board_mock
  end

  describe 'initializer' do
    it 'sets initial meta data' do
      expect(@chart.data['meta']['sprint']).to eq 1
      expect(@chart.data['meta']['total_days']).to eq 10
      expect(@chart.data['meta']['weekend_lines']).to eq [3.5, 8.5]
    end
  end

  describe 'data' do
    use_given_filesystem

    before(:each) do
      @raw_data = [
        {
          'date' => '2014-04-23',
          'updated_at' => '2014-04-23T10:00:00+01:00',
          'story_points' =>
          {
            'total' => 30,
            'open' => 23
          },
          'tasks' =>
          {
            'total' => 25,
            'open' => 21
          }
        },
        {
          'date' => '2014-04-24',
          'updated_at' => '2014-04-24T19:00:00+01:00',
          'story_points' =>
          {
            'total' => 30,
            'open' => 21
          },
          'tasks' =>
          {
            'total' => 26,
            'open' => 19
          },
          'story_points_extra' =>
          {
            'done' => 3
          },
          'tasks_extra' =>
          {
            'done' => 2
          },
          'story_points_unplanned' =>
          {
            'total' => 3,
            'open' => 1
          },
          'tasks_unplanned' =>
          {
            'total' => 2,
            'open' => 1
          }
        }
      ]
    end

    it 'returns sprint number' do
      expect(@chart.sprint).to eq 1
    end

    describe '#add_data' do
      it 'creates first data entry' do
        @burndown_data.story_points.open = 16
        @burndown_data.story_points.done = 7
        @burndown_data.tasks.open = 10
        @burndown_data.tasks.done = 11
        @burndown_data.date_time = DateTime.parse('2014-05-30')

        @chart.add_data(@burndown_data)

        expect( @chart.data['days'].first['story_points'] ).to eq(
          'total' => 23,
          'open' => 16 )
        expect( @chart.data['days'].first['tasks'] ).to eq(
          'total' => 21,
          'open' => 10 )
      end

      it "doesn't overwrite first data entry" do
        @burndown_data.story_points.open = 16
        @burndown_data.story_points.done = 7
        @burndown_data.tasks.open = 10
        @burndown_data.tasks.done = 11
        @burndown_data.date_time = DateTime.parse('2014-05-30')

        @chart.add_data(@burndown_data)

        @burndown_data.story_points.open = 15
        @burndown_data.story_points.done = 8
        @burndown_data.tasks.open = 9
        @burndown_data.tasks.done = 12
        @burndown_data.date_time = DateTime.parse('2014-05-30')

        @chart.add_data(@burndown_data)

        expect( @chart.data['days'].first['story_points'] ).to eq(
          'total' => 23,
          'open' => 16 )
        expect( @chart.data['days'].first['tasks'] ).to eq(
          'total' => 21,
          'open' => 10 )
      end

      it 'does overwrite data entries after first one' do
        @burndown_data.story_points.open = 16
        @burndown_data.story_points.done = 7
        @burndown_data.tasks.open = 10
        @burndown_data.tasks.done = 11
        @burndown_data.date_time = DateTime.parse('2014-05-30')

        @chart.add_data(@burndown_data)

        @burndown_data.story_points.open = 16
        @burndown_data.story_points.done = 7
        @burndown_data.tasks.open = 10
        @burndown_data.tasks.done = 11
        @burndown_data.date_time = DateTime.parse('2014-05-31')

        @chart.add_data(@burndown_data)

        @burndown_data.story_points.open = 15
        @burndown_data.story_points.done = 8
        @burndown_data.tasks.open = 9
        @burndown_data.tasks.done = 12
        @burndown_data.date_time = DateTime.parse('2014-05-31')

        @chart.add_data(@burndown_data)

        expect( @chart.data['days'][1]['story_points'] ).to eq(
          'total' => 23,
          'open' => 15 )
        expect( @chart.data['days'][1]['tasks'] ).to eq(
          'total' => 21,
          'open' => 9 )
      end

      it 'adds data' do
        @chart.data['days'] = @raw_data

        @burndown_data.story_points.open = 16
        @burndown_data.story_points.done = 7
        @burndown_data.tasks.open = 10
        @burndown_data.tasks.done = 11
        @burndown_data.extra_story_points.open = 2
        @burndown_data.extra_story_points.done = 3
        @burndown_data.extra_tasks.open = 5
        @burndown_data.extra_tasks.done = 2
        @burndown_data.date_time = DateTime.parse('2014-05-30')

        @chart.add_data(@burndown_data)

        expect( @chart.data['days'].count ).to eq 3
        expect( @chart.data['days'].last['date'] ).to eq '2014-05-30'
        expect( @chart.data['days'].last['story_points'] ).to eq ( {
          'total' => 23,
          'open' => 16
        } )
        expect( @chart.data['days'].last['tasks'] ).to eq ( {
          'total' => 21,
          'open' => 10
        } )
        expect( @chart.data['days'].last['story_points_extra'] ).to eq ( {
          'done' => 3
        } )
        expect( @chart.data['days'].last['tasks_extra'] ).to eq ( {
          'done' => 2
        } )
      end

      it 'replaces data of same day' do
        @chart.data['days'] = @raw_data

        @burndown_data.story_points.open = 16
        @burndown_data.story_points.done = 7
        @burndown_data.tasks.open = 10
        @burndown_data.tasks.done = 11
        @burndown_data.date_time = DateTime.parse('2014-05-30')

        @chart.add_data(@burndown_data)

        expect( @chart.data['days'].count ).to eq 3
        expect( @chart.data['days'].last['story_points'] ).to eq ( {
          'total' => 23,
          'open' => 16
        } )

        @burndown_data.story_points.done = 8
        @chart.add_data(@burndown_data)

        expect( @chart.data['days'].count ).to eq 3
        expect( @chart.data['days'].last['story_points'] ).to eq ( {
          'total' => 24,
          'open' => 16
        } )
      end
    end

    describe '#read_data' do
      it 'reads data' do
        @chart.read_data given_file('burndown-data.yaml')

        expect(@chart.data['days']).to eq @raw_data
      end

      it 'reads not done columns' do
        @chart.read_data given_file('burndown-data.yaml', from: 'burndown-data-with-config.yaml')
        expect(@settings.not_done_columns).to eq ['Sprint Backlog', 'Doing', 'QA']
      end

      it 'reads swimlanes' do
        @chart.read_data given_file('burndown-data.yaml', from: 'burndown-data-with-swimlanes.yaml')
        expect(@settings.swimlanes).to eq ['Swimlane One', 'swimlanetwo']
      end
    end

    describe '#write_data' do
      it 'writes object to disk' do
        @chart.sprint = 2
        @chart.data['meta']['total_days'] = 9
        @chart.data['meta']['weekend_lines'] = [3.5, 7.5]
        @chart.data['meta']['board_id'] = 'myboardid'
        @chart.data['days'] = @raw_data

        write_path = given_dummy_file
        @chart.write_data(write_path)
        expect(File.read(write_path)). to eq load_test_file('burndown-data.yaml')
      end

      it 'writes all data which was read' do
        read_path = given_file('burndown-data.yaml')
        @chart.read_data(read_path)

        write_path = given_dummy_file
        @chart.write_data(write_path)

        expect(File.read(write_path)).to eq File.read(read_path)
      end

      it "doesn't write extra entries with 0 values" do
        raw_data = [
          {
            'date' => '2014-04-24',
            'story_points' =>
            {
              'total' => 30,
              'open' => 21
            },
            'tasks' =>
            {
              'total' => 26,
              'open' => 19
            },
            'story_points_extra' =>
            {
              'done' => 0
            },
            'tasks_extra' =>
            {
              'done' => 0
            }
          }
        ]
        @chart.data['days'] = raw_data
        @chart.data['meta']['board_id'] = '1234'

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

    describe '#push_to_api' do
      let(:sample_url) { 'http://api.somesite.org/push/1/days' }
      let(:malformed_url) { 'http//api.malformed..urrii/@@@@' }

      it 'check if it raises an expection on malformed url' do
        expect { subject.push_to_api(malformed_url, burndown_data) }
          .to raise_error(TrolloloError)
      end

      it 'push data to api endpoint' do
        stub_request(:post, sample_url).with(body: @chart.data.to_hash.to_json).to_return(status: 200)
        subject.push_to_api(sample_url, @chart.data)
      end
    end
  end

  describe 'commands' do
    use_given_filesystem(keep_files: true)

    describe 'setup' do
      it 'initializes new chart' do
        path = given_directory
        @chart.setup(path, '53186e8391ef8671265eba9d')

        expect(File.exist?(File.join(path, 'burndown-data-01.yaml'))).to be true

        chart = BurndownChart.new(@settings)
        chart.read_data(File.join(path, 'burndown-data-01.yaml'))

        expect(chart.board_id).to eq '53186e8391ef8671265eba9d'
      end
    end

    describe 'last_sprint' do
      it 'gets the last sprint based on the burndown files' do
        path = given_directory_from_data('burndown_dir')
        expect(@chart.last_sprint(path)).to eq(2)
      end
    end

    describe 'load_sprint' do
      let(:path) { given_directory_from_data('burndown_dir') }

      it 'loads the burndown from the 2nd sprint into data' do
        @chart.load_sprint(path)
        expect(@chart.data).to eq(
          'meta' =>
            { 'board_id' => '53186e8391ef8671265eba9d',
              'sprint' => 2,
              'total_days' => 9,
              'weekend_lines' => [3.5, 7.5]
            },
          'days' => [
            { 'date' => '2015-08-28',
              'updated_at' => '2015-08-28T11:04:52+02:00',
              'story_points' =>
                { 'total' => 24.0,
                  'open' => 24.0
                },
              'tasks' =>
                { 'total' => 43,
                  'open' => 28
                },
              'story_points_extra' =>
                { 'done' => 2.0
                },
              'tasks_extra' =>
                { 'done' => 5
                }
            }
          ])
      end

      it 'returns the path of the last sprint' do
        expect(@chart.load_sprint(path)).to eq(File.join(path, 'burndown-data-02.yaml'))
      end
    end

    describe 'update' do
      let(:path) { given_directory_from_data('burndown_dir') }
      let(:options) { {'output' => path, 'board-id' => '7Zar7bNm'} }
      let(:before) { BurndownChart.new(@settings) }
      let(:after) { BurndownChart.new(@settings) }

      it 'updates chart with latest data' do
        updated_at = '2015-01-12T13:57:16+01:00'
        expected_date_time = DateTime.parse(updated_at)
        allow(DateTime).to receive(:now).and_return(expected_date_time)

        before.read_data(File.join(path, 'burndown-data-02.yaml'))
        @chart.update(options)
        after.read_data(File.join(path, 'burndown-data-02.yaml'))
        expect(after.days.size).to eq before.days.size + 1

        expect(after.days.last['date']).to eq '2015-01-12'
        expect(after.days.last['updated_at']).to eq updated_at
      end

      it 'overwrites data on same date' do
        before.read_data(File.join(path, 'burndown-data-02.yaml'))
        @chart.update(options)
        @chart.update(options)
        after.read_data(File.join(path, 'burndown-data-02.yaml'))
        expect(after.days.size).to eq before.days.size + 1
      end

      it 'uses provided board-id' do
        @chart.update(options)
        expect(@chart.board_id).to eq '7Zar7bNm'
      end
    end

    describe 'create_next_sprint' do
      let(:path) { given_directory_from_data('burndown_dir') }
      let(:chart) { BurndownChart.new(@settings) }
      let(:next_sprint_file) { File.join(path, 'burndown-data-03.yaml') }

      it 'create new sprint file' do
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
        chart.create_next_sprint(path)

        expect(File.exist?(next_sprint_file)).to be true
        expect(File.read(next_sprint_file)).to eq expected_file_content
      end

      it 'create new sprint file with params' do
        expected_file_content = <<EOT
---
meta:
  board_id: 53186e8391ef8671265eba9d
  sprint: 3
  total_days: 17
  weekend_lines:
  - 1.5
  - 6.5
  - 11.5
  - 16.5
days: []
EOT
        chart.create_next_sprint(path, total_days: 17, weekend_lines: [1.5, 6.5, 11.5, 16.5])

        expect(File.exist?(next_sprint_file)).to be true
        expect(File.read(next_sprint_file)).to eq expected_file_content
      end
    end
  end

  describe 'reads meta data from the board' do
    use_given_filesystem

    it 'merges meta data from board if present' do
      chart = BurndownChart.new(@settings)
      chart.read_data(given_file('burndown-data-10.yaml'))

      expect(chart.data['meta']['weekend_lines']).to eq([3.5, 8.5])

      burndown = BurndownData.new(@settings)
      burndown.board_id = '53186e8391ef8671265eba9d'
      burndown.fetch

      chart.merge_meta_data_from_board(burndown)

      expect(chart.data['meta']['weekend_lines']).to eq([1.5, 6.5, 11.5, 16.5])
    end
  end

  describe '.plot' do
    it 'sends joined parsed options to python script' do
      allow(described_class).to receive(:process_options).and_return(%w{ --test 1 --no-blah })
      allow(described_class).to receive(:plot_helper).and_return('mescript')
      expect(described_class).to receive(:system).with('python mescript 42 --test 1 --no-blah')
      described_class.plot(42, foo: 1, bar: 2)
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
