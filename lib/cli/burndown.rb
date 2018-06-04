class CliBurndown < Thor
  include CliSettings

  desc 'init', 'Initialize burndown chart'
  option :output, aliases: :o, desc: 'Output directory', required: false
  option 'board-id', desc: 'Id of Trello board', required: true
  def init(command = nil)
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    chart = BurndownChart.new CliSettings.settings
    puts 'Preparing directory...'
    chart.setup(options[:output] || Dir.pwd, CliSettings.board_id(options['board-id']))
  end

  desc 'update', 'Update burndown chart'
  option :output, aliases: :o, desc: 'Output directory', required: false
  option :new_sprint, aliases: :n, desc: 'Create new sprint'
  option :sprint_number, type: :numeric, desc: 'Provide the number of the sprint'
  option :total_days, type: :numeric, desc: 'Provide how many days the sprint longs. 10 days by default'
  option :weekend_lines, type: :array, desc: 'Set the weekend_lines. [3.5, 8.5] by default'
  option :plot, type: :boolean, desc: 'also plot the new data'
  option :plot_to_board, type: :boolean, desc: 'Send the plotted data to the board'
  option 'with-fast-lane', desc: 'Plot Fast Lane with new cards bars', required: false, type: :boolean
  option 'no-tasks', desc: 'Do not plot tasks line', required: false, type: :boolean
  option 'push-to-api', desc: 'Push collected data to api endpoint (in json)', required: false
  option 'board-id', desc: 'Id of Trello Board'
  def update
    CliSettings.process_global_options options
    CliSettings.require_trello_credentials

    chart = BurndownChart.new CliSettings.settings
    begin
      if options[:new_sprint]
        chart.create_next_sprint(options[:output] || Dir.pwd, options)
      end
      chart.update(options)
      puts "Updated data for sprint #{chart.sprint}"
    rescue TrolloloError => e
      STDERR.puts e
      exit 1
    end
  end

  desc 'plot SPRINT-NUMBER [--output] [--no-tasks] [--with-fast-lane]', 'Plot burndown chart for given sprint'
  option :output, aliases: :o, desc: 'Output directory', required: false
  option 'with-fast-lane', desc: 'Plot Fast Lane with new cards bars', required: false, type: :boolean
  option 'no-tasks', desc: 'Do not plot tasks line', required: false, type: :boolean
  def plot(sprint_number)
    CliSettings.process_global_options options
    BurndownChart.plot(sprint_number, options)
  end

  desc 'multi-update', 'run multiple burndowns updates'
  option 'board-list', desc: 'path to board-list.yaml', required: true
  option :plot, type: :boolean, desc: 'also plot the new data'
  option :output, aliases: :o, desc: 'Output directory'
  def multi_update
    CliSettings.process_global_options options
    board_list = YAML.load_file(options['board-list'])
    board_list.each_key do |name|
      raise 'invalid character in team name' if name =~ /[^[:alnum:]. _]/ # sanitize
      board = board_list[name]
      if options['output']
        destdir = File.join(options['output'], name)
      else
        destdir = name
      end
      chart = BurndownChart.new CliSettings.settings
      chart.setup(destdir, board['boardid']) unless File.directory?(destdir)
      chart.update('output' => destdir, plot: options[:plot])
    end
  end
end
