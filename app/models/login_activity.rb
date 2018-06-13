class LoginActivity < ApplicationRecord
  belongs_to :publisher

  default_scope { order(created_at: :asc) }

  def browser
    Browser.new(user_agent, accept_language: accept_language)
  end
end
