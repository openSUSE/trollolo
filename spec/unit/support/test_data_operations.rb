def load_test_file(filename)
  File.read(File.expand_path('../../../data/' + filename, __FILE__))
end

def dummy_settings
  Settings.new(File.expand_path('../../../data/trollolorc', __FILE__))
end

def dummy_card_json
  JSON.parse(File.read(File.expand_path('../../../data/card.json', __FILE__)))
end
