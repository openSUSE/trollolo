require_relative '../../lib/trollolo'
require 'given_filesystem/spec_helpers'
require 'cli_tester'

bin_path = File.expand_path( "../../../bin/", __FILE__ )

if ENV['PATH'] !~ /#{bin_path}/
  ENV['PATH'] = bin_path + File::PATH_SEPARATOR + ENV['PATH']
end

Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }
