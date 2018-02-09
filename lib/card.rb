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
  ESTIMATED_REGEX     = /\(([\d.]+)\)/
  SPRINT_NUMBER_REGEX = /\ASprint (\d+)/

  def initialize(board_data, card_id, settings = nil)
    init_data(board_data, card_id, settings)
  end

  def init_data(board_data, card_id, settings = nil)
    @board_data = board_data
    @settings = settings
    @card_data = @board_data['cards'].find{|c| c['id'] == card_id}
  end

  def as_json
    JSON.pretty_generate(@card_data)
  end

  def estimated?
    name =~ ESTIMATED_REGEX
  end

  def story_points
    return 0.0 unless estimated?
    name.match(ESTIMATED_REGEX).captures.first.to_f
  end

  def done_tasks
    filtered_checklists.map(&:done_tasks).sum
  end

  def tasks
    filtered_checklists.map(&:tasks).sum
  end

  def card_labels
    @card_data['labels']
  end

  def has_label?(label_name)
    card_labels.any? do |label|
      label['name'].include?(label_name)
    end
  end

  def checklists
    @card_data['checklists'].map do |checklist|
      Checklist.new(checklist)
    end
  end

  def filtered_checklists
    checklists.reject do |checklist|
      @settings && @settings.no_task_checklists.include?(checklist.name)
    end
  end

  def desc
    @card_data['desc']
  end

  def extra?
    card_labels.any? do |label|
      label['name'].include?('BelowWaterline') ||
          label['name'].include?('Under waterline')
    end
  end

  def unplanned?
    card_labels.any? do |label|
      label['name'].include?('Unplanned')
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
    card_labels.map{|l| l['name']}.include?('FastLane')
  end

  # TODO: rethink storage for meta data for sprint
  def self.parse_yaml_from_description(description)
    description =~ /```(yaml)?\n(.*)```/m
    yaml = Regexp.last_match(2)
    if yaml
      return YAML.load(yaml) # throws an exception for invalid yaml
    else
      return nil
    end
  end

  def name
    @card_data['name']
  end

  def name=(str)
    @card_data['name'] = str
  end

  def id
    @card_data['id']
  end
end
