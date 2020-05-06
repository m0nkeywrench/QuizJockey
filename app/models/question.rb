class Question < ApplicationRecord
  validates  :sentence, :answer, :wrong1, :wrong2, :wrong3, :course_id, presence: true

  belongs_to :course
end
