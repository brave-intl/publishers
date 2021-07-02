class Redshift < ApplicationRecord
  self.abstract_class = true
  connects_to database: { writing: :stats_redshift, reading: :stats_redshift }
end
