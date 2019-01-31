class Report < ActiveRecord::Base
  belongs_to :partner

  has_one_attached :file
end
