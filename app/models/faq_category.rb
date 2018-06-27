class FaqCategory < ApplicationRecord
  has_many :faqs

  validates :name, presence: true
  validates :rank, presence: true

  default_scope { order(:rank) }

  before_destroy :check_for_faqs

  scope :ready_for_display, -> {
    joins(:faqs).where('faqs.published = true').order('faqs.rank asc').select('DISTINCT faq_categories.*')
  }

  private

  def check_for_faqs
    if faqs.count > 0
      errors.add(:base, "cannot delete faq category while faqs exist")
      throw(:abort)
    end
  end
end
