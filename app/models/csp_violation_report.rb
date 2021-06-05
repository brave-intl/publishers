# frozen_string_literal: true

class CspViolationReport < ApplicationRecord
  validates_uniqueness_of :report
end
