class Build < ApplicationRecord
  belongs_to :user, optional: true
  has_many :build_items, dependent: :destroy
  has_many :parts, through: :build_items

  validates :name, presence: true
end
