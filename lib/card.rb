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

class Card

  attr_accessor :sp, :tasks, :tasks_done

  def self.name_to_points(card_name)
    card_name =~ /^\(([\d.]+)\)/
    return nil if $1.nil?
    $1.to_f
  end

  def initialize
    @sp = nil
    @extra = false
  end
  
  def has_sp?
    @sp != nil
  end
  
  def extra?
    @extra
  end
  
  def set_extra
    @extra = true
  end
  
  def self.parse json
    card = Card.new

    title = json["name"]
    card.sp = name_to_points(title)

    labels = json["labels"]
    labels.each do |label|
      if label["name"] == "Under waterline"
        card.set_extra
      end
    end

    card.tasks = json["badges"]["checkItems"]
    card.tasks_done = json["badges"]["checkItemsChecked"]

    card
  end

end
