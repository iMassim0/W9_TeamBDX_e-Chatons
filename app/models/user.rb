class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :firstname, :lastname, presence: true, format: { with: /\A[-a-zA-Z]*\z/ }

  has_one :cart
  has_many :items, through: :cart
end
