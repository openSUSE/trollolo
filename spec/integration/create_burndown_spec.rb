require_relative "integration_spec_helper"

include GivenFilesystemSpecHelpers
include CliTester

HELPER_SCRIPT = File.expand_path("../../../scripts/create_burndown.py", __FILE__)

describe "create_burndown.py" do
  use_given_filesystem(keep_files: true)

  it "creates burndown chart for sprint 23" do
    @working_dir = given_directory do
      given_file("burndown-data-23.yaml", from: "create_burndown_helper/burndown-data-23.yaml")
    end

    result = run_command(cmd: HELPER_SCRIPT, args: ["23", "--output=#{@working_dir}", "--no-head"])
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-23.png")).
      to be_same_image_as("create_burndown_helper/burndown-23.png")
  end

  it "creates burndown chart for sprint 31" do
    @working_dir = given_directory do
      given_file("burndown-data-31.yaml", from: "create_burndown_helper/burndown-data-31.yaml")
    end

    result = run_command(cmd: HELPER_SCRIPT, args: ["31", "--output=#{@working_dir}", "--no-head"])
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-31.png")).
      to be_same_image_as("create_burndown_helper/burndown-31.png")
  end

  it "creates burndown chart for sprint 35" do
    @working_dir = given_directory do
      given_file("burndown-data-35.yaml", from: "create_burndown_helper/burndown-data-35.yaml")
    end

    result = run_command(cmd: HELPER_SCRIPT, args: ["35", "--output=#{@working_dir}", "--no-head"])
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-35.png")).
      to be_same_image_as("create_burndown_helper/burndown-35.png")
  end

  it "creates burndown chart for sprint 8" do
    @working_dir = given_directory do
      given_file("burndown-data-08.yaml", from: "create_burndown_helper/burndown-data-08.yaml")
    end

    result = run_command(cmd: HELPER_SCRIPT,
      args: ["08", "--output=#{@working_dir}", "--no-tasks", "--with-fast-lane", "--no-head"])
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-08.png")).
      to be_same_image_as("create_burndown_helper/burndown-08.png")
  end
end
