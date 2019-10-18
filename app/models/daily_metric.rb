# frozen_string_literal: true

class DailyMetric < ActiveRecord::Base
  validates_presence_of :name, :result, :date
end
