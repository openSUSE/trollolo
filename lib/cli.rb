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

class Cli < Thor

  default_task :global

  class_option :version, :type => :boolean, :desc => "Show version"
  class_option :verbose, :type => :boolean, :desc => "Verbose mode"
  class_option :raw, :type => :boolean, :desc => "Raw mode"
  class_option "board-id", :type => :string, :desc => "id of Trello board"

  def self.settings= s
    @@settings = s
  end

  desc "global", "Global options", :hide => true
  def global
    if options[:version]
      puts "Trollolo: #{@@settings.version}"
    else
      Cli.help shell
    end
  end

  desc "get-lists", "Get lists"
  option "board-id", :desc => "Id of Trello board", :required => true
  def get_lists
    process_global_options options
    require_trello_credentials

    trello = Trello.new(board_id: options["board-id"], developer_public_key: @@settings.developer_public_key, member_token: @@settings.member_token)
    lists = trello.lists

    if @@settings.raw
      puts JSON.pretty_generate lists
    else
      lists.each do |list|
        puts "#{list[ "name" ]}"
      end
    end
  end

  desc "get-cards", "Get cards"
  option "board-id", :desc => "Id of Trello board", :required => true
  def get_cards
    process_global_options options
    require_trello_credentials

    trello = Trello.new(board_id: options["board-id"], developer_public_key: @@settings.developer_public_key, member_token: @@settings.member_token)
    
    cards = trello.cards

    if @@settings.raw
      puts JSON.pretty_generate cards
    else
      burndown = BurndownData.new @@settings
      burndown.board_id = options["board-id"]

      todo_list_id = burndown.fetch_todo_list_id
      doing_list_id = burndown.fetch_doing_list_id
      done_list_id = burndown.fetch_done_list_id
      
      cards_todo = Array.new
      cards_doing = Array.new
      cards_done = Array.new

      above_waterline = true
      
      cards.each do |card|
        name = card["name"]
        list = card["idList"]
        puts "CARD #{name} (#{list})"
        
        if name == "Waterline"
          above_waterline = false
          next
        end
        
        if Card.name_to_points(name).nil?
          next
        end
        
        if list == todo_list_id && above_waterline
          cards_todo.push card
        elsif list == doing_list_id
          cards_doing.push card
        elsif list == done_list_id
          cards_done.push card
        end
      end

      story_points_todo = 0
      story_points_doing = 0
      story_points_done = 0
      
      puts
      
      puts "Todo"
      cards_todo.each do |card|
        puts "  #{card["name"]}"
        story_points_todo += Card.name_to_points(card["name"])
      end

      puts "Doing"
      cards_doing.each do |card|
        puts "  #{card["name"]}"
        story_points_doing += Card.name_to_points(card["name"])
      end

      puts "Done"
      cards_done.each do |card|
        puts "  #{card["name"]}"
        story_points_done += Card.name_to_points(card["name"])
      end
      
      puts
      
      story_points_total = story_points_todo + story_points_doing + story_points_done
      
      puts "Done: #{story_points_done}/#{story_points_total} (#{story_points_doing} in progress)"
    end
  end

  desc "get-checklists", "Get checklists"
  option "board-id", :desc => "Id of Trello board", :required => true
  def get_checklists
    process_global_options options
    require_trello_credentials

    trello = Trello.new(board_id: options["board-id"], developer_public_key: @@settings.developer_public_key, member_token: @@settings.member_token)
    
    data = trello.checklists

    puts JSON.pretty_generate data
  end

  desc "fetch-burndown-data", "Fetch data for burndown chart"
  option "board-id", :desc => "Id of Trello board", :required => true
  def fetch_burndown_data
    process_global_options options
    require_trello_credentials

    burndown = BurndownData.new @@settings
    burndown.board_id = options["board-id"]
    burndown.fetch
        
    puts "Story points:"
    puts "   Open: #{burndown.story_points.open}"
    puts "   Done: #{burndown.story_points.done}"
    puts "  Total: #{burndown.story_points.total}"    
    puts "Tasks:"
    puts "   Open: #{burndown.tasks.open}"
    puts "   Done: #{burndown.tasks.done}"
    puts "  Total: #{burndown.tasks.total}"    
    puts
    puts "Extra story points:"
    puts "   Open: #{burndown.extra_story_points.open}"
    puts "   Done: #{burndown.extra_story_points.done}"
    puts "  Total: #{burndown.extra_story_points.total}"    
    puts "Extra tasks:"
    puts "   Open: #{burndown.extra_tasks.open}"
    puts "   Done: #{burndown.extra_tasks.done}"
    puts "  Total: #{burndown.extra_tasks.total}"
  end
  
  desc "burndown-init", "Initialize burndown chart"
  option :output, :aliases => :o, :desc => "Output directory", :required => true
  option "board-id", :desc => "Id of Trello board", :required => true
  def burndown_init command=nil
    process_global_options options
    require_trello_credentials

    chart = BurndownChart.new @@settings
    puts "Preparing directory..."
    chart.setup(options[:output],options["board-id"])
  end
  
  desc "burndown", "Update burndown chart"
  option :output, :aliases => :o, :desc => "Output directory", :required => false
  option :new_sprint, :aliases => :n, :desc => "Create new sprint"
  def burndown
    process_global_options options
    require_trello_credentials

    chart = BurndownChart.new @@settings
    begin
      if options[:new_sprint]
        chart.create_next_sprint(options[:output] || Dir.pwd)
      end
      chart.update(options[:output] || Dir.pwd)
    rescue TrolloloError => e
      STDERR.puts e
      exit 1
    end
  end
  
  desc "plot SPRINT-NUMBER", "Plot burndown chart for given sprint"
  def plot(sprint_number)
    process_global_options options
    BurndownChart.plot(sprint_number)
  end

  desc "backup", "Create backup of board"
  option "board-id", :desc => "Id of Trello board", :required => true
  def backup
    process_global_options options
    b = Backup.new @@settings
    b.backup(options["board-id"])
  end

  desc "list_backups", "List all backups"
  def list_backups
    b = Backup.new @@settings
    b.list.each do |backup|
      puts backup
    end
  end

  desc "show_backup", "Show backup of board"
  option "board-id", :desc => "Id of Trello board", :required => true
  def show_backup
    b = Backup.new @@settings
    b.show(options["board-id"])
  end

  private
  
  def process_global_options options
    @@settings.verbose = options[:verbose]
    @@settings.raw = options[:raw]
  end

  def require_trello_credentials
    write_back = false

    if !@@settings.developer_public_key
      puts "Put in Trello developer public key:"
      @@settings.developer_public_key = STDIN.gets.chomp
      write_back = true
    end
    
    if !@@settings.member_token
      puts "Put in Trello member token:"
      @@settings.member_token = STDIN.gets.chomp
      write_back = true
    end

    if write_back
      @@settings.save_config
    end
    
    if !@@settings.developer_public_key || !@@settings.member_token
      STDERR.puts "Require trello credentials in config file"
      exit 1
    end
  end
end
