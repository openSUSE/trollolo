require_relative '../spec_helper'

describe Scrum::Creator do
  subject { described_class.new(dummy_settings) }
  let(:custom_subject) do
    custom_settings = dummy_settings
    custom_settings.scrum.board_names['planning'] = 'Planungs Brett'
    described_class.new(custom_settings)
  end
  let(:board_id) { 123 }
  let(:board) { double('trello-board', id: board_id) }
  let(:planning_board_id) { 999 }
  let(:planning_board) { double('other-trello-board', id: planning_board_id) }

  it 'creates new creator' do
    expect(subject).to be
  end

  context 'default' do
    it 'creates boards from default config' do
      expect(Trello::Board).to receive(:create).with(name: 'Sprint Board').and_return(board)
      expect(Trello::Board).to receive(:create).with(name: 'Planning Board').and_return(planning_board)

      expect_scrum_lists_and_labels

      expect { subject.create }.not_to raise_error
    end

    it 'creates boards according to existing config' do
      expect(Trello::Board).to receive(:create).with(name: 'Sprint Board').and_return(board)
      expect(Trello::Board).to receive(:create).with(name: 'Planungs Brett').and_return(planning_board)

      expect_scrum_lists_and_labels

      expect { custom_subject.create }.not_to raise_error
    end
  end

  def expect_scrum_lists_and_labels
    expect(Trello::List).to receive(:create).with(board_id: board_id, name: 'Sprint Backlog')
    expect(Trello::List).to receive(:create).with(board_id: board_id, name: 'QA')
    expect(Trello::List).to receive(:create).with(board_id: board_id, name: 'Doing')
    %w[Sticky Waterline].each do |name|
      expect(Trello::Label).to receive(:create).with(board_id: board_id, name: name)
    end

    expect(Trello::List).to receive(:create).with(board_id: planning_board_id, name: 'Backlog')
    expect(Trello::List).to receive(:create).with(board_id: planning_board_id, name: 'Ready for Estimation')
    %w[Sticky Waterline].each do |name|
      expect(Trello::Label).to receive(:create).with(board_id: planning_board_id, name: name)
    end
  end
end
