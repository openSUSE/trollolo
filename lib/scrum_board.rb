class ScrumBoard

  class DoneColumnNotFoundError < StandardError; end
  class AcceptedColumnNotFoundError < StandardError; end

  def initialize(board_data, settings = nil)
    @settings = settings
    @board_data = board_data
  end

  def columns
    @columns ||= @board_data['lists'].map{|x| Column.new(@board_data, x['id'], @settings)}
  end

  def planning_backlog_column
    columns.select{ |column| column.name == @settings.scrum['list_names']['planning_backlog'] }.first
  end

  def todo_columns
    columns.select{|c| @settings.todo_columns.include?(c.name)}
  end

  def doing_columns
    columns.select{|c| @settings.doing_columns.include?(c.name) }
  end

  def done_column
    done_columns = columns.select{|c| c.name =~ @settings.done_column_name_regex }
    if done_columns.empty?
      raise DoneColumnNotFoundError, "can't find done column by name regex #{@settings.done_column_name_regex}"
    else
      done_columns.max_by{|c| c.name.match(@settings.done_column_name_regex).captures.first.to_i }
    end
  end

  def accepted_columns
    columns.select{|c| c.name =~ @settings.accepted_column_name_regex }
  end

  def accepted_column
    if accepted_columns.empty?
      EmptyColumn.new
    else
      accepted_columns.max_by{|c| c.name.match(@settings.accepted_column_name_regex).captures.first.to_i }
    end
  end

  def done_cards
    done_column.committed_cards + accepted_column.committed_cards
  end

  def open_columns
    todo_columns + doing_columns
  end

  def open_cards
    open_columns.map(&:committed_cards).flatten
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
    (done_column.extra_cards + accepted_column.extra_cards + open_columns.map(&:extra_cards)).flatten(1)
  end

  def extra_done_cards
    done_column.extra_cards + accepted_column.extra_cards
  end

  def extra_done_story_points
    extra_done_cards.map(&:story_points).sum
  end

  def extra_open_cards
    open_columns.map{|col| col.cards.select(&:extra?) }.flatten
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


  def unplanned_cards
    (done_column.unplanned_cards + accepted_column.unplanned_cards + open_columns.map(&:unplanned_cards)).flatten(1)
  end

  def unplanned_done_cards
    done_column.unplanned_cards + accepted_column.unplanned_cards
  end

  def unplanned_done_story_points
    unplanned_done_cards.map(&:story_points).sum
  end

  def unplanned_open_cards
    open_columns.map{|col| col.cards.select(&:unplanned?) }.flatten
  end

  def unplanned_open_story_points
    unplanned_open_cards.map(&:story_points).sum
  end

  def unplanned_tasks
    unplanned_cards.map(&:tasks).sum
  end

  def unplanned_closed_tasks
    unplanned_cards.map(&:done_tasks).sum
  end


  def open_fast_lane_cards_count
    open_columns.map(&:fast_lane_cards).flatten(1).count
  end

  def done_fast_lane_cards_count
    done_column.fast_lane_cards.count + accepted_column.fast_lane_cards.count
  end

  def scrum_cards
    open_columns.map(&:fast_lane_cards).flatten(1) + done_column.cards + accepted_column.cards
  end

  def meta_cards
    scrum_cards.select(&:meta_card?)
  end

  def id
    @board_data['id']
  end

  def cards
    @cards ||= columns.map(&:cards).flatten
  end

  def burndown_card_id
    done_column.cards[0].id
  end
end
