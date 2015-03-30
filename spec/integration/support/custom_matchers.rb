RSpec::Matchers.define :be_same_image_as do |expected|
  match do |actual|
    expected_path = File.expand_path('../../../data/' + expected, __FILE__)
    expected_file = File.binread(expected_path)
    actual_file = File.binread(actual)

    expected_file == actual_file
  end

  description do
    "be the same image as \"#{expected}\""
  end
end
