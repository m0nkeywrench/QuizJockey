class Course < ApplicationRecord
  validates  :name, presence: true
  validates  :private, inclusion: {in: [true, false]}

  belongs_to :user
  has_many   :questions, dependent: :delete_all
end
