require 'benchmark'
require 'ostruct'

class ScrumBoard

  class DoneColumnNotFoundError < StandardError; end

  def initialize(trello_board, settings)
    @trello_board = trello_board
    @settings     = settings
  end

  def columns
    @columns ||= @trello_board.lists.map{|x| Column.new(x)}
  end

  def done_column
    begin
      columns.select{|c| c.name =~ @settings.done_column_name_regex }
          .max_by{|c| c.name.match(@settings.done_column_name_regex).captures.first.to_i }
    rescue
      raise DoneColumnNotFoundError, "can't find done column by name regex #{@settings.done_column_name_regex}"
    end
  end

  def done_cards
    done_column.committed_cards
  end

  def open_columns
    columns.select{ |col| @settings.not_done_columns.include?(col.name) }
  end

  def open_cards
    open_columns.map{|col| col.committed_cards}.flatten
  end

  def committed_cards
    open_cards + done_cards
  end

  def done_story_points
    done_cards.map(&:story_points).sum
  end

  def open_story_points
    open_cards.map(&:story_points).sum
  end

  def closed_tasks
    committed_cards.map(&:done_tasks).sum
  end

  def tasks
    committed_cards.map(&:tasks).sum
  end

  def extra_cards
    (done_column.extra_cards + open_columns.map(&:extra_cards)).flatten(1)
  end

  def extra_done_cards
    done_column.extra_cards
  end

  def extra_done_story_points
    extra_done_cards.map(&:story_points).sum
  end

  def extra_open_cards
    open_columns.map{|col| col.cards.select{|c| c.extra?}}.flatten
  end

  def extra_open_story_points
    extra_open_cards.map(&:story_points).sum
  end

  def extra_tasks
    extra_cards.map(&:tasks).sum
  end

  def extra_closed_tasks
    extra_cards.map(&:done_tasks).sum
  end

  def open_fast_lane_cards_count
    open_columns.map(&:fast_lane_cards).flatten(1).count
  end

  def done_fast_lane_cards_count
    done_column.fast_lane_cards.count
  end

  def scrum_cards
    open_columns.map(&:fast_lane_cards).flatten(1) + done_column.cards
  end

  def backup
    @trello_board.client.get("/boards/#{@trello_board.id}?lists=all&cards=all")
  end

  def meta_cards
    scrum_cards.select{|c| c.meta_card? }
  end

  def method_missing(*args)
    @trello_board.send(*args)
  end

end
