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

def compare_images_for_sprint(sprint_number, extra_args = [])
  @working_dir = given_directory do
    given_file("burndown-data-#{sprint_number}.yaml", from: "create_burndown_helper/burndown-data-#{sprint_number}.yaml")
  end

  result = run_helper(@working_dir, sprint_number, extra_args)
  expect(result).to exit_with_success("")
  expect(File.join(@working_dir, "burndown-#{sprint_number}.png")).
    to be_same_image_as("create_burndown_helper/burndown-#{sprint_number}.png")
end

describe "create_burndown.py" do
  use_given_filesystem(keep_files: true)

  before(:all) do
    if `docker images -q trollolo-matplotlib`.empty?
      raise "Required docker image 'trollolo-matplotlib' not found. Build it with 'docker build -t trollolo-matplotlib spec/containers/matplotlib'"
    end
  end

  it "creates burndown chart with varying number of total story points and tasks" do
    compare_images_for_sprint("23")
  end

  it "creates burndown chart with done tasks at the beginning" do
    compare_images_for_sprint("31")
  end

  it "creates burndown chart of unfinished sprint" do
    compare_images_for_sprint("35")
  end

  it "creates burndown chart with fast lane and no tasks" do
    compare_images_for_sprint("08", ["--no-tasks", "--with-fast-lane"])
  end

  it "creates perfect burndown chart" do
    compare_images_for_sprint("42")
  end

  it "creates burndown chart with unplanned cards" do
    compare_images_for_sprint("56")
  end
end
