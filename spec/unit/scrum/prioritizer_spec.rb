require_relative '../spec_helper'

describe Scrum::Prioritizer do
  subject(:prioritizer) do
    prioritizer = described_class.new(dummy_settings)
    prioritizer.setup_boards(
      planning_board: boards.planning_board(trello_planning_board)
    )
  end

  let(:boards) { Scrum::Boards.new(dummy_settings.scrum) }
  let(:trello_planning_board) { double(lists: lists) }
  let(:lists) { [list] }
  let(:list) { double('list', name: 'Backlog', cards: []) }

  it 'creates new prioritizer' do
    expect(prioritizer).to be
  end

  context 'when list is missing' do
    let(:lists) { [] }

    it 'raises an exception if list is not on board' do
      expect { prioritizer.prioritize }.to raise_error("list named 'Backlog' not found on board")
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
      expect { prioritizer.prioritize }.not_to raise_error
    end
  end

  context 'when specifying backlog list as argument' do
    subject(:prioritizer) do
      prioritizer = described_class.new(dummy_settings)
      prioritizer.setup_boards(planning_board: boards.planning_board(trello_planning_board, list_name))
    end

    context 'when list exists' do
      let(:list_name) { 'Backlog' }

      it 'finds backlog list' do
        expect do
          prioritizer.prioritize
        end.not_to raise_error
      end
    end

    context 'when list is missing' do
      let(:list_name) { 'My Backlog' }

      it 'throws error when specified list does not exist' do
        expect { prioritizer.prioritize }.to raise_error("list named 'My Backlog' not found on board")
      end
    end
  end

  context 'when settings specify different list' do
    let(:boards) do
      settings = dummy_settings.scrum.dup
      settings.list_names['planning_backlog'] = 'Nonexisting List'
      Scrum::Boards.new(settings)
    end

    it 'throws error' do
      expect { prioritizer.prioritize }.to raise_error("list named 'Nonexisting List' not found on board")
    end
  end
end
