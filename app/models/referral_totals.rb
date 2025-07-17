class ReferralTotals < ApplicationRecord
  has_paper_trail

  self.per_page = 50

  belongs_to :publisher

  validates_presence_of :total

  before_save :sync_paid_at_with_paid

  def sync_paid_at_with_paid
    if paid_changed?
      if paid
        paid_at = DateTime.current
      else
        paid_at = nil
      end
    end
  end
end
