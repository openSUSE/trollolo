require_relative 'spec_helper'

include GivenFilesystemSpecHelpers

describe BurndownPlot do
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