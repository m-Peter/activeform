require 'test_helper'

class AttributeWhitelistTest < ActiveSupport::TestCase
  include ActiveForm

  test "create new attribute whitelist" do
    attrs = [:name, :age]
    list = AttributeWhitelist.new(attrs)

    assert list.whitelisted_attrs.include?(:name)
    assert list.whitelisted_attrs.include?(:age)
  end

  test "#allows method" do
    attrs = [:name, :age]
    list = AttributeWhitelist.new(attrs)

    assert list.allows?(:name)
    assert list.allows?(:age)
    assert list.allows?(:id)
    assert list.allows?(:_destroy)
    assert_not list.allows?(:gender)
  end
end