# typed: ignore

class UpdateOfacListJob < ApplicationJob
  queue_as :scheduler

  def perform
    new_ofac_list = ParseOfacListService.perform[:addresses]
    raise 'Empty list' unless new_ofac_list.present?
    list = new_ofac_list.map{|addr| OfacAddress.new(address: addr)}
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.truncate_tables(*[:ofac_addresses])
      OfacAddress.import list
    end
  end
end
