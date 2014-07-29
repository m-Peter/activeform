class User < ActiveRecord::Base
  act_as_gendered
  has_one :email, dependent: :destroy
  has_one :profile, dependent: :destroy

  validates :name, uniqueness: true
end
