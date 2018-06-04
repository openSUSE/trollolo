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

  include CliSettings

  default_task :global

  class_option :version, type: :boolean, desc: 'Show version'
  class_option :verbose, type: :boolean, desc: 'Verbose mode'
  class_option :raw, type: :boolean, desc: 'Raw mode'

  desc 'global', 'Global options', hide: true
  def global
    if options[:version]
      puts "Trollolo: #{CliSettings.settings.version}"
    else
      Cli.help shell
    end
  end

  desc 'get SUBCOMMAND ...ARGS', 'get various types of data from board'
  subcommand 'get', CliGet

  desc 'set SUBCOMMAND ...ARGS', 'set some attributes on the board'
  subcommand 'set', CliSet

  desc 'backup SUBCOMMAND ...ARGS', 'commands to use the backup of the board'
  subcommand 'backup', CliBackup

  desc 'scrum SUBCOMMAND ...ARGS', 'commands to use the scrum workflow'
  subcommand 'scrum', CliScrum

  desc 'burndown SUBCOMMAND ...ARGS', 'commands to use the burndown workflow'
  subcommand 'burndown', CliBurndown
end
