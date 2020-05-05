class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :password, :name, format: { with: /\A[a-z0-9]+\z/i }
  validates :name, :nickname, null: false
  validates :name, uniqueness: true
end
