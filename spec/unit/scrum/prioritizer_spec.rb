require_relative '../spec_helper'

describe Scrum::Prioritizer do
  subject { described_class.new(dummy_settings) }
  let(:trello_planning_board) { double(lists: lists) }
  let(:lists) { [list] }

  it 'creates new prioritizer' do
    expect(subject).to be
  end

  context 'when list is missing' do
    let(:lists) { [] }

    it 'raises an exception if list is not on board' do
      expect { subject.prioritize(trello_planning_board) }.to raise_error("list named 'Backlog' not found on board")
    end
  end

  context 'when list is present' do
    let(:sticky_card) { double('sticky-card', labels: [double(name: 'Sticky')]) }
    let(:card) { double('card', name: 'Task 1', labels: []) }
    let(:list) { double('list', name: 'Backlog', cards: [sticky_card, card]) }

    it 'adds priority text to card titles' do
      expect(card).to receive(:name=).with('P1: Task 1')
      expect(card).to receive(:save)
      expect(STDOUT).to receive(:puts).exactly(1).times
      expect { subject.prioritize(trello_planning_board) }.not_to raise_error
    end
  end

  context 'when specifying backlog list as argument' do
    let(:list) { double('list', name: 'Backlog', cards: []) }

    before do
      subject.settings.scrum.list_names['planning_backlog'] = 'Nonexisting List'
    end

    it 'finds backlog list' do
      expect do
        subject.prioritize(trello_planning_board, 'Backlog')
      end.not_to raise_error
    end

    it 'throws error when default list does not exist' do
      expect { subject.prioritize(trello_planning_board) }.to raise_error("list named 'Nonexisting List' not found on board")
    end

    it 'throws error when specified list does not exist' do
      expect { subject.prioritize(trello_planning_board, 'My Backlog') }.to raise_error("list named 'My Backlog' not found on board")
    end
  end
end
