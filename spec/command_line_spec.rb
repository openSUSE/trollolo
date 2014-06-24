require_relative 'spec_helper'

require "aruba/api"

include Aruba::Api
include GivenFilesystemSpecHelpers

def trollolo_cmd
  File.expand_path('../wrapper/trollolo_wrapper',__FILE__)
end

def trollolo_cmd_empty_config
  File.expand_path('../wrapper/empty_config_trollolo_wrapper',__FILE__)
end

def credentials_input_wrapper
  File.expand_path('../wrapper/credentials_input_wrapper',__FILE__)
end

describe "command line" do

  it "processes help option" do
    run "trollolo -h"
    assert_exit_status_and_partial_output 0, "Commands:"
    assert_partial_output "trollolo help", all_output
    assert_partial_output "Options:", all_output
  end

  it "throws error on invalid command" do
    run "#{trollolo_cmd} invalid_command"
    assert_exit_status 1
  end
  
  it "asks for authorization data" do
    run "#{credentials_input_wrapper} get-cards --board-id=myboardid"
    assert_exit_status 0
  end

  describe "burndown chart" do
    use_given_filesystem
    
    it "inits burndown directory" do
      path = given_directory
      run "#{trollolo_cmd} burndown-init -o #{path} --board-id=myboardid"
      assert_exit_status 0
    end
    
    it "fails, if burndown data is not found" do
      path = given_directory
      run "#{trollolo_cmd} burndown -o #{path}"
      assert_exit_status 1
      assert_partial_output "burndown-data-01.yaml' not found", all_stderr
    end
  end
  
end
