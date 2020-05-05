class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :password, :name, format: { with: /\A[a-z0-9]+\z/i }
  validates :name, :nickname, presence: true
  validates :name, uniqueness: true

  has_many :courses, dependent: :destroy
end
