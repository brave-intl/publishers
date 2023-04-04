# typed: strict

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: {writing: :primary, reading: :secondary}
end
