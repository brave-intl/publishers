class ServiceRun < ApplicationRecord
  validates :service_name, presence: true

  scope :for_service, ->(service) { where(service_name: service_name_for(service)) }
  scope :most_recent_first, -> { order(created_at: :desc) }

  def self.record_success!(service)
    create!(service_name: service_name_for(service))
  end

  def self.last_success_at(service)
    for_service(service).maximum(:created_at)
  end

  def self.service_name_for(service)
    service.is_a?(String) ? service : service.name
  end
end
