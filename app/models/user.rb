class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, format: { with: /\A[a-z0-9]+\z/i }
  validates :password, presence: true, on: :create
  validates :password, format: { with: /\A[a-z0-9]+\z/i }, on: :update, allow_blank: true
  validates :name, :nickname, presence: true
  validates :name, uniqueness: true

  has_many :courses, dependent: :destroy
end
