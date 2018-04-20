class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def initialize_id
    self.id = SecureRandom.uuid
  end
end
