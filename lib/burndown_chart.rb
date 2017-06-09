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
class BurndownChart

  attr_accessor :data

  def initialize(settings)
    @settings = settings

    @data = {
      "meta" => {
        "board_id" => nil,
        "done_column_id" => nil,
        "sprint" => 1,
        "total_days" => 10,
        "weekend_lines" => [ 3.5, 8.5 ]
      },
      "days" => []
    }
  end

  def sprint
    @data["meta"]["sprint"]
  end

  def sprint= s
    @data["meta"]["sprint"] = s
  end

  def board_id
    @data["meta"]["board_id"]
  end

  def board_id= id
    @data["meta"]["board_id"] = id
  end

  def days
    @data["days"]
  end

  def merge_meta_data_from_board(burndown_data)
    if burndown_data.meta
      m = burndown_data.meta
      if m["sprint"] == @data["meta"]["sprint"].to_i
        @data["meta"] = @data["meta"].merge(m)
      end
    end
  end

  def replace_entry(date, new_entry)
    days.each_with_index do |entry, idx|
      days[idx] = new_entry if entry["date"] == date.to_s
    end
  end

  def entry_exists?(date)
    days.any? { |entry| entry["date"] == date.to_s }
  end

  def add_data(burndown_data)
    new_entry = burndown_data.to_hash
    if entry_exists?(burndown_data.date_time.to_date) && days.length > 1
      replace_entry(burndown_data.date_time.to_date, new_entry)
    else
      days.push(new_entry)
    end
  end

  def read_data filename
    @data = YAML.load_file filename
    not_done_columns = @data["meta"]["not_done_columns"]
    if not_done_columns
      @settings.not_done_columns = not_done_columns
    end
  end

  def write_data filename
    @data["days"].each do |day|
      [ "story_points_extra", "tasks_extra" ].each do |key|
        if day[key] && day[key]["done"] == 0
          day.delete key
        end
      end
    end

    # update the column id to the most left done column
    @data['meta']['done_column_id'] = TrelloWrapper.new(@settings).board(board_id).done_column.id

    begin
      File.open( filename, "w" ) do |file|
        file.write @data.to_yaml
      end
    rescue Errno::ENOENT
      raise TrolloloError.new( "'#{filename}' not found" )
    end
  end


  # Writes a POST request to url
  def push_to_api(url, burndown_data)

    url = url.gsub(':sprint', sprint.to_s)
      .gsub(':board', board_id.to_s)

    begin
      uri       = URI.parse(url)
      push      = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
      push.body = burndown_data.to_hash.to_json

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(push)
      end
    rescue StandardError => e
      # Instead of catching 20 different exceptions which can be
      # thrown by URI and Http::, StandardError is catched.
      # Fix this if there is a better solution
      raise TrolloloError.new("pushing to endpoint failed: #{e.message}")
    end
  end


  def burndown_data_filename
    "burndown-data-#{sprint.to_s.rjust(2,"0")}.yaml"
  end

  def setup(burndown_dir, board_id)
    self.board_id       = board_id
    FileUtils.mkdir_p burndown_dir
    write_data File.join(burndown_dir, burndown_data_filename)
  end

  class << self

    def plot_helper
      File.expand_path('../../scripts/create_burndown.py', __FILE__ )
    end

    def plot(sprint_number, options)
      sprint_number = sprint_number.to_s.rjust(2, '0')
      cli_switches = process_options(options)
      system "python #{plot_helper} #{sprint_number} #{cli_switches.join(' ')}"
    end

    def new_sprint_started?(settings, dir)
      sprint_file = Dir.glob("#{dir}/burndown-data-*.yaml").max_by do |file|
        file.match(/burndown-data-(\d+).yaml/).captures.first.to_i
      end

      begin
        sprint = YAML.load_file(sprint_file)
      rescue SyntaxError, SystemCallError => e
        raise Trollolo.new("Loading #{sprint_file} failed: #{e.message}")
      end

      # Current file does not support auto creating new sprints
      return false if sprint['meta']['done_column_id'].nil?

      # current sprint on trello board
      trello = TrelloWrapper.new(settings).board(sprint['meta']['board_id'])

      if sprint['meta']['done_column_id'] != trello.done_column.id
        return true
      end
      return false
    end

    private

    def process_options(hash)
      return [] unless hash
      [].tap do |cli_switches|
        cli_switches << '--no-tasks'                 if hash['no-tasks']
        cli_switches << '--with-fast-lane'           if hash['with-fast-lane']
        cli_switches << "--output #{hash['output']}" if hash['output']
        cli_switches << '--verbose'                  if hash['verbose']
      end
    end

  end

  def last_sprint(burndown_dir)
    last_sprint = sprint
    Dir.glob("#{burndown_dir}/burndown-data-*.yaml").each do |file|
      file =~ /burndown-data-(.*).yaml/
      current_sprint = $1.to_i
      if current_sprint > last_sprint
        last_sprint = current_sprint
      end
    end
    last_sprint
  end

  def load_last_sprint(burndown_dir)
    self.sprint = last_sprint(burndown_dir)
    burndown_data_path = File.join(burndown_dir, burndown_data_filename)
    begin
      read_data burndown_data_path
    rescue Errno::ENOENT
      raise TrolloloError.new( "'#{burndown_data_path}' not found" )
    end
    return burndown_data_path
  end

  def update(options)
    burndown_data_path = load_last_sprint(options['output'] || Dir.pwd)

    burndown_data = BurndownData.new(@settings)
    burndown_data.board_id = board_id
    burndown_data.fetch

    add_data(burndown_data)

    write_data(burndown_data_path)

    if options[:plot]
      BurndownChart.plot(self.sprint, options)
    end

    if options.has_key?('push-to-api')
      push_to_api(options['push-to-api'], data)
    end
  end

  def create_next_sprint(burndown_dir)
    load_last_sprint(burndown_dir)
    self.sprint = self.sprint + 1
    @data["days"] = []
    write_data File.join(burndown_dir, burndown_data_filename)
  end

end
