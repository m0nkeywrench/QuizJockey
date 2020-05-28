class Course < ApplicationRecord
  validates  :name, presence: true
  validates  :private, inclusion: {in: [true, false]}

  belongs_to :user
  has_many   :questions, dependent: :delete_all

  # 問題数0かつ非公開のクイズをカット 要書き換え
  def self.get_course_list
    courses = self.joins(:questions).preload(:questions).where(private: false).includes(:questions, :user)
    return courses
  end
end
