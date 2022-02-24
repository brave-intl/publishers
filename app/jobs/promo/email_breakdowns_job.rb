# typed: false
class Promo::EmailBreakdownsJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: true

  def perform(publisher_id, type)
    Promo::EmailBreakdownsService.build.call(publisher_id, type)
  end
end
