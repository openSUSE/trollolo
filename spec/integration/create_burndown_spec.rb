require_relative "integration_spec_helper"

include GivenFilesystemSpecHelpers

HELPER_SCRIPT = File.expand_path("../../../scripts/create_burndown.py", __FILE__)

describe "create_burndown.py" do
  use_given_filesystem(keep_files: true)

  before(:each) do
    @working_dir = given_directory do
      given_file("burndown-data-35.yaml", from: "create_burndown_helper/burndown-data-35.yaml")
    end
  end

  it "creates burndown chart" do
    cmd = "#{HELPER_SCRIPT} 35 #{@working_dir}"
    run(cmd)
    assert_exit_status(0)
    expect(File.join(@working_dir, "burndown-35.png")).
      to be_same_image_as("create_burndown_helper/burndown-35.png")
  end
end
