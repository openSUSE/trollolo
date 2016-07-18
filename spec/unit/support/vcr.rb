require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = "spec/data/vcr"
  config.hook_into :webmock
end

RSpec.configure do |c|
  c.around do |example|
    if cassette = example.metadata[:vcr]
      VCR.use_cassette(cassette) do
        example.run
      end
    else
      example.run
    end
  end
end
