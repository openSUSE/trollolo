require_relative 'integration_spec_helper'

include GivenFilesystemSpecHelpers
include CliTester

def trollolo_cmd
  File.expand_path('../wrapper/trollolo_wrapper', __FILE__)
end

def trollolo_cmd_empty_config
  File.expand_path('../wrapper/empty_config_trollolo_wrapper', __FILE__)
end

def credentials_input_wrapper
  File.expand_path('../wrapper/credentials_input_wrapper', __FILE__)
end

describe 'command line' do

  it 'processes help option' do
    result = run_command(args: ['-h'])
    expect(result).to exit_with_success(/Commands:/)
    expect(result.stdout).to match('trollolo help')
    expect(result.stdout).to match('Options:')
  end

  it 'throws error on invalid command' do
    result = run_command(cmd: trollolo_cmd, args: ['invalid_command'])
    expect(result).to exit_with_error(1, "Could not find command \"invalid_command\".\n")
  end

  it 'asks for authorization data' do
    expect(run_command(cmd: credentials_input_wrapper, args: ['get-cards', '--board-id=myboardid'])).to exit_with_success('')
  end

  describe 'burndown chart' do
    use_given_filesystem

    it 'inits burndown directory' do
      path = given_directory
      result = run_command(cmd: trollolo_cmd, args: ['burndown-init', '-o', path.to_s, '--board-id=myboardid'])
      expect(result).to exit_with_success(/Preparing/)
    end

    it 'fails, if burndown data is not found' do
      path = given_directory
      result = run_command(cmd: trollolo_cmd, args: ['burndown', '-o', path.to_s])
      expect(result).to exit_with_error(1, /burndown-data-01.yaml' not found/)
    end
  end

end
