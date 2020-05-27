class Course < ApplicationRecord
  validates  :name, presence: true
  validates  :private, inclusion: {in: [true, false]}

  belongs_to :user
  has_many   :questions, dependent: :delete_all

  def self.get_course_list
    courses = self.where(private: false).includes(:questions, :user)
    available_courses = courses.select do |course|
      course.questions.length > 0
    end
    return available_courses
  end
end
