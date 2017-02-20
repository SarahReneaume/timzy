class Website < ApplicationRecord
  #validations
  validates :url, :name, presence: true
  #associations
  belongs_to :analytic
  belongs_to :team
end