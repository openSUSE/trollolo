class ScrumBoard

  class DoneColumnNotFoundError < StandardError; end

  def initialize(board_data, settings)
    @settings = settings
    @board_data = board_data
  end

  def columns
    @columns ||= @board_data["lists"].map{|x| Column.new(@board_data, x["id"])}
  end

  def done_column
    begin
      done_columns = columns.select{|c| c.name =~ @settings.done_column_name_regex }
      if done_columns.empty?
        raise DoneColumnNotFoundError, "can't find done column by name regex #{@settings.done_column_name_regex}"
      else
        done_columns.first
      end
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

  def meta_cards
    scrum_cards.select{|c| c.meta_card? }
  end

  def id
    @board_data["id"]
  end
end
