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

  attr_accessor :story_points, :tasks, :extra_story_points, :extra_tasks
  attr_accessor :board_id
  
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

  def initialize settings
    @settings = settings

    @story_points = Result.new
    @tasks = Result.new

    @extra_story_points = Result.new
    @extra_tasks = Result.new
  end

  def trello
    Trello.new(board_id: @board_id, developer_public_key: @settings.developer_public_key, member_token: @settings.member_token)
  end

  def meta
    @meta
  end

  def fetch_list_id_regexp(regexp)
    lists = trello.lists
    lists.each do |l|
      if l["name"] =~ /#{regexp}/
        return l["id"]
      end
    end
    return nil
  end

  def fetch_todo_list_id
    return(fetch_list_id_regexp("^Sprint Backlog$") or raise "Unable to find sprint backlog column on sprint board")
  end

  def fetch_doing_list_id
    return(fetch_list_id_regexp("^Doing$") or raise "Unable to find doing column on sprint board")
  end

  def fetch_done_list_id
    lists = trello.lists
    last_sprint = nil
    lists.each do |l|
      if l["name"] =~ /^Done Sprint (.*)$/
        sprint = $1.to_i
        if !last_sprint || sprint > last_sprint[:number]
          last_sprint = { :number => sprint, :id => l["id"] }
        end
      end
    end

    id = last_sprint[:id]
    if !id
      raise "Unable to find done column on sprint board"
    end
    id
  end
  
  def fetch
    cards = trello.cards

    todo_list_id = fetch_todo_list_id
    doing_list_id = fetch_doing_list_id
    blocked_list_id = fetch_list_id_regexp("^Blocked")
    done_list_id = fetch_done_list_id
    
    if @settings.verbose
      puts "Todo list: #{todo_list_id}"
      puts "Doing list: #{doing_list_id}"
      puts "Blocked list: #{blocked_list_id}"
      puts "Done list: #{done_list_id}"
    end

    sp_total = 0
    sp_done = 0
    
    extra_sp_total = 0
    extra_sp_done = 0

    tasks_total = 0
    tasks_done = 0
    
    extra_tasks_total = 0
    extra_tasks_done = 0
    
    cards.each do |c|
      card = Card.parse c
      
      list_id = c["idList"]

      if list_id == todo_list_id || list_id == doing_list_id || list_id == blocked_list_id
        if card.has_sp?
          if card.extra?
            extra_sp_total += card.sp
          else
            sp_total += card.sp
          end
        end
        if card.extra?
          extra_tasks_total += card.tasks
          extra_tasks_done += card.tasks_done
        else
          tasks_total += card.tasks
          tasks_done += card.tasks_done
        end
      elsif list_id == done_list_id
        if card.meta
          @meta=card.meta
        end
        if card.has_sp?
          if card.extra?
            extra_sp_total += card.sp
            extra_sp_done += card.sp
          else
            sp_total += card.sp
            sp_done += card.sp
          end
        end
        if card.extra?
          extra_tasks_total += card.tasks
          extra_tasks_done += card.tasks_done
        else
          tasks_total += card.tasks
          tasks_done += card.tasks_done
        end
      end
    end
    
    @story_points.done = sp_done
    @story_points.open = sp_total - sp_done
    
    @tasks.done = tasks_done
    @tasks.open = tasks_total - tasks_done

    @extra_story_points.done = extra_sp_done
    @extra_story_points.open = extra_sp_total - extra_sp_done
    
    @extra_tasks.done = extra_tasks_done
    @extra_tasks.open = extra_tasks_total - extra_tasks_done
  end

end
