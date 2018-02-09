#  Copyright (c) 2013-2014 SUSE LLC
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 3 of the GNU General Public License as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.
#
#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

# This class represents the current state of burndown data on the Trello board.
# It encapsulates getting the data from Trello. It does not keep any history
# or interaction with the files used to generate burndown charts.
class BurndownData

  class Result
    attr_accessor :open, :done

    def initialize
      @open = 0
      @done = 0
    end

    def total
      @open + @done
    end
  end

  class SwimlaneResult
    attr_accessor :todo, :doing, :done

    def add_todo(story_points)
      @todo += story_points
    end

    def add_doing(story_points)
      @doing += story_points
    end

    def add_done(story_points)
      @done += story_points
    end

    def initialize
      @todo = 0
      @doing = 0
      @done = 0
    end
  end

  attr_accessor :story_points, :tasks, :extra_story_points, :extra_tasks,
                :unplanned_story_points, :unplanned_tasks,
                :board_id, :fast_lane_cards, :date_time, :swimlanes
  attr_reader :meta

  def initialize(settings)
    @settings               = settings
    @story_points           = Result.new
    @tasks                  = Result.new
    @extra_story_points     = Result.new
    @extra_tasks            = Result.new
    @unplanned_story_points = Result.new
    @unplanned_tasks        = Result.new
    @fast_lane_cards        = Result.new
    @date_time              = Time.now

    @swimlanes              = {}
    settings.swimlanes.each do |swimlane|
      @swimlanes[swimlane] = SwimlaneResult.new
    end
  end

  def to_hash
    base = {
      'date' => date_time.to_date.to_s,
      'updated_at' => date_time.to_s,
      'story_points' => {
        'total' => story_points.total,
        'open' => story_points.open
      },
      'tasks' => {
        'total' => tasks.total,
        'open' => tasks.open
      },
      'story_points_extra' => {
        'done' => extra_story_points.done
      },
      'tasks_extra' => {
        'done' => extra_tasks.done
      }
    }

    base['fast_lane'] = fast_lane_to_hash if fast_lane_cards.total > 0

    if unplanned_story_points.total > 0
      base['unplanned_story_points'] = {
        'total' => unplanned_story_points.total,
        'open' => unplanned_story_points.open
      }
      base['unplanned_tasks'] = {
        'total' => unplanned_tasks.total,
        'open' => unplanned_tasks.open
      }
    end

    base['swimlanes'] = swimlanes_to_hash unless swimlanes.empty?

    base
  end

  def fast_lane_to_hash
    {
      'total' => fast_lane_cards.total,
      'open' => fast_lane_cards.open
    }
  end

  def swimlanes_to_hash
    swimlanes_element = {}
    swimlanes.each do |name, swimlane_result|
      swimlanes_element[name] = {
        'todo' => swimlane_result.todo,
        'doing' => swimlane_result.doing,
        'done' => swimlane_result.done
      }
    end
    swimlanes_element
  end

  def trello
    @trello ||= TrelloWrapper.new(@settings)
  end

  def board
    trello.board(@board_id)
  end

  def fetch
    @meta = get_meta
    @story_points.done       = board.done_story_points
    @story_points.open       = board.open_story_points
    @tasks.open              = board.tasks - board.closed_tasks
    @tasks.done              = board.closed_tasks
    @extra_story_points.done = board.extra_done_story_points
    @extra_story_points.open = board.extra_open_story_points
    @extra_tasks.done        = board.extra_closed_tasks
    @extra_tasks.open        = board.extra_tasks - board.extra_closed_tasks
    @unplanned_story_points.done = board.unplanned_done_story_points
    @unplanned_story_points.open = board.unplanned_open_story_points
    @unplanned_tasks.done = board.unplanned_closed_tasks
    @unplanned_tasks.open = board.unplanned_tasks - board.unplanned_closed_tasks
    @fast_lane_cards.done    = board.done_fast_lane_cards_count
    @fast_lane_cards.open    = board.open_fast_lane_cards_count
    @date_time               = DateTime.now

    fetch_swimlanes
  end

  def fetch_swimlanes
    @settings.swimlanes.each do |swimlane|
      board.todo_columns.each do |column|
        column.cards.each do |card|
          @swimlanes[swimlane].add_todo(card.story_points) if card.label?(swimlane)
        end
      end

      board.doing_columns.each do |column|
        column.cards.each do |card|
          @swimlanes[swimlane].add_doing(card.story_points) if card.label?(swimlane)
        end
      end

      board.done_column.cards.each do |card|
        @swimlanes[swimlane].add_done(card.story_points) if card.label?(swimlane)
      end
      board.accepted_column.cards.each do |card|
        @swimlanes[swimlane].add_done(card.story_points) if card.label?(swimlane)
      end
    end
  end

  private

  def get_meta
    meta_cards = board.meta_cards
    return nil unless meta_cards.any?
    current_sprint_meta_card = meta_cards.max_by(&:sprint_number)
    meta = Card.parse_yaml_from_description(current_sprint_meta_card.desc)
    return nil unless meta
    meta['sprint'] = current_sprint_meta_card.sprint_number
    meta
  end

end
