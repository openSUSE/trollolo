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

  # Assuming we have card titles as follows '(8) This is the card name'
  ESTIMATED_REGEX     = /\A\(([\d.]+)\)/
  SPRINT_NUMBER_REGEX = /\ASprint (\d+)/

  def initialize(trello_card)
    @trello_card = trello_card
  end

  def estimated?
    name =~ ESTIMATED_REGEX
  end

  def story_points
    return 0.0 unless estimated?
    name.match(ESTIMATED_REGEX).captures.first.to_f
  end

  def done_tasks
    @trello_card.badges['checkItemsChecked'].to_f
  end

  def tasks
    @trello_card.badges['checkItems'].to_f
  end

  def extra?
    self.card_labels.any? do |label|
      label['name'].include?('BelowWaterline') ||
          label['name'].include?('Under waterline')
    end
  end

  def meta_card?
    name =~ SPRINT_NUMBER_REGEX
  end

  def sprint_number
    raise ArgumentError unless meta_card?
    name.match(SPRINT_NUMBER_REGEX).captures.first.to_i
  end

  def fast_lane?
    # TODO: move to settings
    self.card_labels.map{|l| l['name']}.include?('FastLane')
  end

  #TODO: rethink storage for meta data for sprint
  def self.parse_yaml_from_description(description)
    description =~ /```(yaml)?\n(.*)```/m
    yaml = $2
    if yaml
      return YAML.load(yaml) # throws an exception for invalid yaml
    else
      return nil
    end
  end

  def self.parse(json)
    Card.new(Trello::Card.new(json))
  end

  def method_missing(*args)
    @trello_card.send(*args)
  end

end
