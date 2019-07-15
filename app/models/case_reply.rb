
class CaseReply < ApplicationRecord
  validates :title, :body, presence: true, allow_blank: false
end
