class Faq < ApplicationRecord
  belongs_to :faq_category

  validates :faq_category, presence: true
  validates :rank, presence: true
  validates :question, presence: true
  validates :answer, presence: true

  default_scope { order(:rank) }
end
