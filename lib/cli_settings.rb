module CliSettings
  def self.settings=(s)
    @@settings = s
  end

  def self.settings
    @@settings
  end

  def self.process_global_options(options)
    @@settings.verbose = options[:verbose]
    @@settings.raw = options[:raw]
  end

  def self.require_trello_credentials
    write_back = false

    unless @@settings.developer_public_key
      puts 'Put in Trello developer public key:'
      @@settings.developer_public_key = STDIN.gets.chomp
      write_back = true
    end

    unless @@settings.member_token
      puts 'Put in Trello member token:'
      @@settings.member_token = STDIN.gets.chomp
      write_back = true
    end

    @@settings.save_config if write_back

    if !@@settings.developer_public_key || !@@settings.member_token
      STDERR.puts 'Require trello credentials in config file'
      exit 1
    end
  end

  # Returns the board_id using id_or_alias. If id_or_alias matches a mapping
  # from trollolorc then the mapped id is returned or else the id_or_alias
  # is returned.
  def self.board_id(id_or_alias)
    @@settings.board_aliases[id_or_alias] || id_or_alias
  end

  def self.board_from_id(id_or_alias)
    Trello::Board.find(board_id(id_or_alias))
  end
end
