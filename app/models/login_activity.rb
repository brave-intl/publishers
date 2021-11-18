# typed: strict
class LoginActivity < ApplicationRecord
  belongs_to :publisher

  default_scope { order(created_at: :asc) }
end
