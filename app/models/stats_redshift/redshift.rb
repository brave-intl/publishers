# typed: strict

class Redshift < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: {writing: :stats_redshift, reading: :stats_redshift} unless Rails.env.test?
end
