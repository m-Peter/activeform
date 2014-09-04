require "test_helper"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests ActiveForm::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  test "assert app folder contains forms sub-folder" do
    gen = generator
    gen.create_forms_app_directory
    assert_directory "app/forms"
  end

  test "assert test folder contains forms sub-folder" do
    gen = generator
    gen.create_forms_test_directory
    assert_directory "test/forms"
  end
end
