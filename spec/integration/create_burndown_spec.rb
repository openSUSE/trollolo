require_relative "integration_spec_helper"

include GivenFilesystemSpecHelpers

HELPER_SCRIPT = File.expand_path("../../../scripts/create_burndown.py", __FILE__)

describe "create_burndown.py" do
  use_given_filesystem(keep_files: true)

  it "creates burndown chart for sprint 23" do
    @working_dir = given_directory do
      given_file("burndown-data-23.yaml", from: "create_burndown_helper/burndown-data-23.yaml")
    end

    cmd = "#{HELPER_SCRIPT} 23 --output=#{@working_dir}"
    run(cmd)
    assert_exit_status(0)
    expect(File.join(@working_dir, "burndown-23.png")).
      to be_same_image_as("create_burndown_helper/burndown-23.png")
  end

  it "creates burndown chart for sprint 31" do
    @working_dir = given_directory do
      given_file("burndown-data-31.yaml", from: "create_burndown_helper/burndown-data-31.yaml")
    end

    cmd = "#{HELPER_SCRIPT} 31 --output=#{@working_dir}"
    run(cmd)
    assert_exit_status(0)
    expect(File.join(@working_dir, "burndown-31.png")).
      to be_same_image_as("create_burndown_helper/burndown-31.png")
  end

  it "creates burndown chart for sprint 35" do
    @working_dir = given_directory do
      given_file("burndown-data-35.yaml", from: "create_burndown_helper/burndown-data-35.yaml")
    end

    cmd = "#{HELPER_SCRIPT} 35 --output=#{@working_dir}"
    run(cmd)
    assert_exit_status(0)
    expect(File.join(@working_dir, "burndown-35.png")).
      to be_same_image_as("create_burndown_helper/burndown-35.png")
  end

  it "creates burndown chart for sprint 8" do
    @working_dir = given_directory do
      given_file("burndown-data-08.yaml", from: "create_burndown_helper/burndown-data-08.yaml")
    end

    cmd = "#{HELPER_SCRIPT} 08 --output=#{@working_dir} --no-tasks --with-fast-lane"
    run(cmd)
    assert_exit_status(0)
    expect(File.join(@working_dir, "burndown-08.png")).
      to be_same_image_as("create_burndown_helper/burndown-08.png")
  end
end
