class UserForm < ActiveForm::Base
  attributes :name, :age, :gender, required: true

  association :email do
    attribute :address, required: true
  end

  association :profile do
    attributes :twitter_name, :github_name, required: true
  end
  
  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }
end