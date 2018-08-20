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
require 'fileutils'

class BurndownChart

  attr_accessor :data

  def initialize(settings)
    @settings = settings

    @data = {
      'meta' => {
        'board_id' => nil,
        'sprint' => 1,
        'total_days' => 10,
        'weekend_lines' => [ 3.5, 8.5 ]
      },
      'days' => []
    }
  end

  def sprint
    @data['meta']['sprint']
  end

  def sprint=(s)
    @data['meta']['sprint'] = s
  end

  def board_id
    @data['meta']['board_id']
  end

  def board_id=(id)
    @data['meta']['board_id'] = id
  end

  def days
    @data['days']
  end

  def merge_meta_data_from_board(burndown_data)
    if burndown_data.meta
      m = burndown_data.meta
      if m['sprint'] == @data['meta']['sprint'].to_i
        @data['meta'] = @data['meta'].merge(m)
      end
    end
  end

  def replace_entry(date, new_entry)
    days.each_with_index do |entry, idx|
      days[idx] = new_entry if entry['date'] == date.to_s
    end
  end

  def entry_exists?(date)
    days.any? { |entry| entry['date'] == date.to_s }
  end

  def add_data(burndown_data)
    new_entry = burndown_data.to_hash
    if entry_exists?(burndown_data.date_time.to_date) && days.length > 1
      replace_entry(burndown_data.date_time.to_date, new_entry)
    else
      days.push(new_entry)
    end
  end

  def read_data(filename)
    @data = YAML.load_file filename

    todo_columns = @data['meta']['todo_columns']
    @settings.todo_columns = todo_columns if todo_columns

    doing_columns = @data['meta']['doing_columns']
    @settings.doing_columns = doing_columns if doing_columns

    if @data['meta']['not_done_columns']
      raise '`not_done_columns` is deprecated. Use `todo_columns` and `doing_columns` instead.'
    end

    @settings.swimlanes = @data['meta']['swimlanes'] || []
  end

  def write_data(filename)
    @data['days'].each do |day|
      %w[story_points_extra tasks_extra].each do |key|
        day.delete key if day[key] && day[key]['done'] == 0
      end
    end

    begin
      File.open( filename, 'w' ) do |file|
        file.write @data.to_yaml
      end
    rescue Errno::ENOENT
      raise TrolloloError, "'#{filename}' not found"
    end
  end


  # Writes a POST request to url
  def push_to_api(url, burndown_data)

    url = url.gsub(':sprint', sprint.to_s)
      .gsub(':board', board_id.to_s)

    begin
      uri       = URI.parse(url)
      push      = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      push.body = burndown_data.to_hash.to_json

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(push)
      end
    rescue StandardError => e
      # Instead of catching 20 different exceptions which can be
      # thrown by URI and Http::, StandardError is catched.
      # Fix this if there is a better solution
      raise TrolloloError, "pushing to endpoint failed: #{e.message}"
    end
  end


  def burndown_data_filename
    "burndown-data-#{sprint.to_s.rjust(2, '0')}.yaml"
  end

  def setup(burndown_dir, board_id)
    self.board_id = board_id
    FileUtils.mkdir_p burndown_dir
    write_data File.join(burndown_dir, burndown_data_filename)
  end

  def last_sprint(burndown_dir)
    last_sprint = sprint
    Dir.glob("#{burndown_dir}/burndown-data-*.yaml").each do |file|
      file =~ /burndown-data-(.*).yaml/
      current_sprint = Regexp.last_match(1).to_i
      last_sprint = current_sprint if current_sprint > last_sprint
    end
    last_sprint
  end

  # It loads the sprint for the given number or the last one if it is nil
  def load_sprint(burndown_dir, number = nil)
    self.sprint = number || last_sprint(burndown_dir)
    burndown_data_path = File.join(burndown_dir, burndown_data_filename)
    begin
      read_data burndown_data_path
    rescue Errno::ENOENT
      raise TrolloloError, "'#{burndown_data_path}' not found"
    end
    burndown_data_path
  end

  def update(options)
    burndown_data_path = load_sprint(options['output'] || Dir.pwd, options[:sprint_number])

    @data['meta']['board_id'] = options['board-id'] if options.key?('board-id')
    burndown_data = BurndownData.new(@settings)
    burndown_data.board_id = board_id
    burndown_data.fetch

    add_data(burndown_data)

    write_data(burndown_data_path)

    if options[:plot] || options[:plot_to_board]
      BurndownPlot.plot(sprint, options)
    end

    push_to_api(options['push-to-api'], data) if options.key?('push-to-api')

    if options[:plot_to_board]
      trello = TrelloWrapper.new(@settings)
      board = trello.board(board_id)
      name = options['output'] ? options['output'] : '.'
      name += "/burndown-#{sprint.to_s.rjust(2, '0')}.png"
      card_id = board.burndown_card_id

      response = trello.add_attachment(card_id, name)

      if /{\"id\":\"(?<attachment_id>\w+)\"/ =~ response
        trello.make_cover_with_id(card_id, attachment_id)
      end
    end
  end

  def create_next_sprint(burndown_dir, options = {})
    load_sprint(burndown_dir)
    self.sprint = options[:sprint_number] || (sprint + 1)
    @data['meta']['total_days'] = options[:total_days] if options[:total_days]
    @data['meta']['weekend_lines'] = options[:weekend_lines] unless options[:weekend_lines].blank?
    @data['days'] = []
    write_data File.join(burndown_dir, burndown_data_filename)
  end
end
