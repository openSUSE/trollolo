require_relative '../spec_helper'

shared_examples 'sprint_board_creation' do |list_name|
  context 'when backlog is missing' do
    let(:list) { double('list', name: 'Unrelated List') }

    it 'raises an error message' do
      expect do
        boards.sprint_board(sprint_board)
      end.to raise_error("sprint board is missing the backlog list named: '#{list_name}'")
    end
  end

  context 'when backlog is present' do
    let(:list) { double('list', name: list_name) }

    it 'returns a sprint board class' do
      expect(boards.sprint_board(sprint_board)).to be_a_kind_of(Scrum::SprintBoard)
    end
  end
end

shared_examples 'planning_board_creation' do |list_name, list_name_arg|
  context 'when backlog is missing' do
    let(:list) { double('list', name: 'Unrelated List') }

    it 'raises an error message' do
      expect do
        boards.planning_board(planning_board, list_name_arg)
      end.to raise_error("planning board is missing the backlog list named: '#{list_name}'")
    end
  end

  context 'when backlog is present' do
    let(:list) { double('list', name: list_name) }

    it 'returns a sprint board class' do
      expect(boards.planning_board(planning_board, list_name_arg)).to be_a_kind_of(Scrum::SprintPlanningBoard)
    end
  end
end

describe Scrum::Boards do
  subject(:boards) { described_class.new(scrum_settings) }

  let(:scrum_settings) { dummy_settings.scrum }

  context '#sprint_board' do
    let(:sprint_board) { double('sprint-board', lists: [list]) }

    include_examples 'sprint_board_creation', 'Sprint Backlog'

    context 'when settings specify different lists' do
      let(:scrum_settings) do
        settings = dummy_settings.scrum.dup
        settings.list_names['sprint_backlog'] = 'Different List'
        settings
      end

      include_examples 'sprint_board_creation', 'Different List'
    end
  end

  context '#planning_board' do
    let(:planning_board) { double('planning-board', lists: [list]) }

    include_examples 'planning_board_creation', 'Backlog', nil

    context 'when specifying backlog list as argument' do
      include_examples 'planning_board_creation', 'Name Argument', 'Name Argument'
    end

    context 'when settings specify different lists' do
      let(:scrum_settings) do
        settings = dummy_settings.scrum.dup
        settings.list_names['planning_backlog'] = 'Different List'
        settings
      end

      include_examples 'planning_board_creation', 'Different List', nil
    end
  end
end
