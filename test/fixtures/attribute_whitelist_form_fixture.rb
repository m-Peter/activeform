class AttributeWhitelistFormFixture < ActiveForm::Base
  self.main_model = :user

  attributes :name, :age, :gender
end