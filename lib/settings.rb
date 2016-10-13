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

class Settings

  attr_accessor :developer_public_key, :member_token, :board_aliases, :verbose,
                :raw, :not_done_columns, :todo_column, :accepted_column_name_regex,
                :done_column_name_regex, :todo_column_name_regex

  def initialize config_file_path
    @config_file_path = config_file_path
    if File.exists? config_file_path
      @config = YAML.load_file(config_file_path)

      if @config
        @developer_public_key       = @config["developer_public_key"]
        @member_token               = @config["member_token"]
        @board_aliases              = @config["board_aliases"] || {}
        @not_done_columns           = @config["not_done_columns"].freeze || ["Sprint Backlog", "Doing"]
        @todo_column                = @config["todo_column"].freeze
        @done_column_name_regex     = @config["done_column_name_regex"].freeze || /\ADone/
        @accepted_column_name_regex = @config["accepted_column_name_regex"].freeze || /\AAccepted/
        @todo_column_name_regex     = @config["todo_column_name_regex"].freeze || /\ATo Do\Z/
      else
        raise "Couldn't read config data from '#{config_file_path}'"
      end
    end

    @verbose = false
    @raw = false
  end

  def save_config
    @config = {}
    @config["developer_public_key"] = @developer_public_key
    @config["member_token"] = @member_token

    File.open(@config_file_path,"w") do |f|
      f.write(@config.to_yaml)
    end
  end

  def version
    Trollolo::VERSION
  end

end
