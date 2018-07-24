class BurndownPlot
  def self.plot(sprint_number, options)
    sprint_number = sprint_number.to_s.rjust(2, '0')
    cli_switches = process_options(options)
    system "python #{plot_helper} #{sprint_number} #{cli_switches.join(' ')}"
  end

  def self.plot_helper
    File.expand_path('../../scripts/create_burndown.py', __FILE__)
  end

  def self.process_options(hash)
    return [] unless hash
    [].tap do |cli_switches|
      cli_switches << '--no-tasks'                 if hash['no-tasks']
      cli_switches << '--with-fast-lane'           if hash['with-fast-lane']
      cli_switches << "--output #{hash['output']}" if hash['output']
      cli_switches << '--verbose'                  if hash['verbose']
    end
  end
end
