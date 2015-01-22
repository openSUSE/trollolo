require 'spec_helper'

describe ScrumBoard do

  let(:settings) { dummy_settings }
  let(:trello_board) { double('Trello Board') }

  subject { described_class.new(trello_board, settings) }

  describe '#done_column' do

    it 'raises error when done column cannot be found' do
      allow(trello_board).to receive(:lists).and_raise('me broken')
      expect{subject.done_column}.to raise_error ScrumBoard::DoneColumnNotFoundError
    end

  end

end
