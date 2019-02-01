class Report < ActiveRecord::Base
  belongs_to :partner

  has_one_attached :file

  def filename
    self.file.filename if self.file.attached?
  end
end
