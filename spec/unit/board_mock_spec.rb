require_relative 'spec_helper'

describe BoardMock do
  context 'one column' do
    let :subject do
      BoardMock.new
        .list('One')
    end

    it 'has one column' do
      expect(subject.columns.count).to eq(1)
    end

    it 'has no cards' do
      expect(subject.cards.count).to eq(0)
    end
  end

  context 'two columns' do
    let :subject do
      board = BoardMock.new
      board.list('One')
      board.list('Two')
      board
    end

    it 'has two columns' do
      expect(subject.columns.count).to eq(2)
    end

    it 'has no cards' do
      expect(subject.cards.count).to eq(0)
    end
  end

  context 'one column and two cards' do
    let :subject do
      board = BoardMock.new
      list = board.list('One')
      list.card('Red')
      list.card('Green')
      board
    end

    it 'has one column' do
      expect(subject.columns.count).to eq(1)
    end

    it 'has two cards' do
      expect(subject.cards.count).to eq(2)
    end
  end

  context 'two columns and two cards each' do
    let :subject do
      BoardMock.new
        .list('One')
          .card('Red')
          .card('Green')
        .list('Two')
          .card('Blue')
          .card('Yellow')
    end

    it 'has two columns' do
      expect(subject.columns.count).to eq(2)
    end

    it 'has four cards' do
      expect(subject.cards.count).to eq(4)
    end

    it 'has two cards in each list' do
      subject.columns.each do |column|
        expect(column.cards.count).to eq(2)
      end
    end
  end

  context 'one card with one label' do
    let :subject do
      BoardMock.new
        .list('One')
          .card('Red')
            .label('Cold')
    end

    it 'has one card' do
      expect(subject.cards.count).to eq(1)
    end

    it 'card has one label' do
      expect(subject.cards.first.label?('Cold'))
    end
  end
end
