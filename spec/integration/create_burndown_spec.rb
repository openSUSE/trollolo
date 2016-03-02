require_relative "integration_spec_helper"

include GivenFilesystemSpecHelpers
include CliTester

def run_helper(working_dir, sprint_number, extra_args = [])
  helper_dir = File.expand_path("../../../scripts", __FILE__)
  args = ["run"]
  args += ["-v", "#{helper_dir}:/trollolo/helper"]
  args += ["-v", "#{working_dir}:/trollolo/data"]
  args += ["-w", "/trollolo/data"]
  args += ["matplotlib"]
  args += ["/trollolo/helper/create_burndown.py", sprint_number]
  args += extra_args
  run_command(cmd: "docker", args: args)
end

describe "create_burndown.py" do
  use_given_filesystem(keep_files: true)

  before(:all) do
    if `docker images -q trollolo-matplotlib`.empty?
      raise "Required docker image 'trollolo-matplotlib' not found. Build it with 'docker build -t trollolo-matplotlib spec/containers/matplotlib'"
    end
  end

  it "creates burndown chart for sprint 23" do
    @working_dir = given_directory do
      given_file("burndown-data-23.yaml", from: "create_burndown_helper/burndown-data-23.yaml")
    end

    result = run_helper(@working_dir, "23")
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-23.png")).
      to be_same_image_as("create_burndown_helper/burndown-23.png")
  end

  it "creates burndown chart for sprint 31" do
    @working_dir = given_directory do
      given_file("burndown-data-31.yaml", from: "create_burndown_helper/burndown-data-31.yaml")
    end

    result = run_helper(@working_dir, "31")
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-31.png")).
      to be_same_image_as("create_burndown_helper/burndown-31.png")
  end

  it "creates burndown chart for sprint 35" do
    @working_dir = given_directory do
      given_file("burndown-data-35.yaml", from: "create_burndown_helper/burndown-data-35.yaml")
    end

    result = run_helper(@working_dir, "35")
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-35.png")).
      to be_same_image_as("create_burndown_helper/burndown-35.png")
  end

  it "creates burndown chart for sprint 8" do
    @working_dir = given_directory do
      given_file("burndown-data-08.yaml", from: "create_burndown_helper/burndown-data-08.yaml")
    end

    result = run_helper(@working_dir, "08", ["--no-tasks", "--with-fast-lane"])
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-08.png")).
      to be_same_image_as("create_burndown_helper/burndown-08.png")
  end

  it "creates perfect burndown chart" do
    @working_dir = given_directory do
      given_file("burndown-data-42.yaml", from: "create_burndown_helper/burndown-data-42.yaml")
    end

    result = run_helper(@working_dir, "42")
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-42.png")).
      to be_same_image_as("create_burndown_helper/burndown-42.png")
  end

  it "creates burndown chart with unplanned cards" do
    @working_dir = given_directory do
      given_file("burndown-data-56.yaml", from: "create_burndown_helper/burndown-data-56.yaml")
    end

    result = run_helper(@working_dir, "56")
    expect(result).to exit_with_success("")
    expect(File.join(@working_dir, "burndown-56.png")).
      to be_same_image_as("create_burndown_helper/burndown-56.png")
  end
end
