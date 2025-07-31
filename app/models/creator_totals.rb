class CreatorTotals < ApplicationRecord
  has_paper_trail

  self.per_page = 50

  belongs_to :publisher

  validates_presence_of :total

  before_save :sync_paid_at_with_paid

  def sync_paid_at_with_paid
    if paid_changed?
      self.paid_at = if paid
        DateTime.current
      end
    end
  end
end
