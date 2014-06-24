require_relative '../lib/trollolo'

require 'given_filesystem/spec_helpers'
require 'webmock/rspec'

bin_path = File.expand_path( "../../bin/", __FILE__ )

if ENV['PATH'] !~ /#{bin_path}/
  ENV['PATH'] = bin_path + File::PATH_SEPARATOR + ENV['PATH']
end

def load_test_file filename
  File.read(File.expand_path('../data/' + filename,__FILE__))
end

def dummy_settings
  Settings.new( File.expand_path('../data/trollolorc',__FILE__) )
end
