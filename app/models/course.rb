class Course < ApplicationRecord
  validates  :name, presence: true
  validates  :private, inclusion: {in: [true, false]}

  belongs_to :user
  has_many   :questions, dependent: :delete_all

  # 問題数0かつ非公開のクイズをカット 要書き換え
  def self.get_course_list
    self.joins(:questions).includes(:questions, :user).where(private: false)
  end

  # ページネーション
  def self.paginate(page)
    self.page(page).per(8).order(created_at: :desc)
  end

  # 検索 なぜかjoinsが使えないので問題数0の問題カットはビューの方に任せる
  def self.search(search)
    return self.get_course_list unless search
    self.where('name LIKE(?)', "%#{search}%").where(private: false).includes(:questions, :user)
  end
end
