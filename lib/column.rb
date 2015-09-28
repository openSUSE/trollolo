#  Copyright (c) 2013-2015 SUSE LLC
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
class Column
  def initialize(board_data, list_id)
    @board_data = board_data
    @list_data = @board_data["lists"].select{|l| l["id"] == list_id}.first
  end

  def id
    @list_data['id']
  end

  def name
    @list_data["name"]
  end

  def estimated_cards
    cards.select{|x| x.estimated? }
  end

  def sum
    estimated_cards.map{|x| x.story_points}.sum
  end

  def tasks
    cards.map(&:tasks).sum
  end

  def done_tasks
    cards.map(&:done_tasks).sum
  end

  def extra_cards
    cards.select{|c| c.extra?}
  end

  def committed_cards
    cards.select{|c| !c.extra?}
  end

  def fast_lane_cards
    cards.select{|c| c.fast_lane?}
  end

  def cards
    return @cards if @cards

    cards = @board_data["cards"].select{|c| c["idList"] == @list_data["id"]}
    @cards = cards.map{|c| Card.new(@board_data, c["id"])}
  end
end
