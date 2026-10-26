# typed: ignore

class UpdateProhibitedListJob < ApplicationJob
  queue_as :scheduler

  def perform
    new_prohibited_list = ParseProhibitedListService.perform[:addresses]
    raise "Empty list" unless new_prohibited_list.present?
    list = new_prohibited_list.map { |addr| ProhibitedList.new(address: addr) }
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.truncate_tables(:prohibited_list)
      ProhibitedList.import list
    end
  end
end
