require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = 'spec/data/vcr'
  config.hook_into :webmock
end

# example needs to use real_settings if vcr_record: true is used
def real_settings
  config_path = ENV['TROLLOLO_CONFIG_PATH'] || File.expand_path('~/.trollolorc')
  Settings.new(config_path)
end

def real_settings_needed?(example)
  example.metadata[:vcr_record] && Trello.configuration.developer_public_key == 'mykey'
end

def cassette_path(cassette)
  File.join(VCR.configuration.cassette_library_dir, cassette + '.yml')
end

def vcr_record?(example)
  example.metadata[:vcr_record]
end

def vcr_record_mode(example)
  return :all if vcr_record?(example)
  :none
end

def vcr_replace_tokens(cassette_path)
  settings = real_settings
  text = File.read(cassette_path)
  File.open(cassette_path, 'w') do |f|
    text.gsub!(settings.member_token, 'mytoken')
    text.gsub!(settings.developer_public_key, 'mykey')
    f.print text
  end
end

RSpec.configure do |c|
  c.around do |example|
    if (cassette = example.metadata[:vcr])
      raise 'you need to use real_settings to re-record vcr data' if real_settings_needed?(example)
      VCR.use_cassette(cassette, record: vcr_record_mode(example)) do
        example.run
      end
      vcr_replace_tokens(cassette_path(cassette)) if vcr_record?(example)
    else
      example.run
    end
  end
end
