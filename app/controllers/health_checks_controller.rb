class HealthChecksController < ActionController::Base
  def show
    @services = system_status
    @healthy = healthy?(@services)

    respond_to do |format|
      format.html {}
      format.json { render json: { healthy: @healthy, services: @services }, status: @healthy ? 200 : 503 }
    end
  end

  private

  def system_status
    [
      { name: "cache", healthy: cache_connected? },
      { name: "database", healthy: database_connected? },
      { name: "mailer_queue", healthy: mailer_queue_low? },
      { name: "system_time", healthy: system_time_current_year? },
    ]
  end

  def system_time_current_year?
    DateTime.now.to_s.starts_with?("202")
  end

  def healthy?(status)
    status.all? { |s| s[:optional] || s[:healthy] }
  end

  def cache_connected?
    REDIS.with do |conn|
      conn.ping == "PONG"
    end
  rescue StandardError
    false
  end

  def database_connected?
    ApplicationRecord.connection
    ApplicationRecord.connected?
  rescue
    false
  end

  def mailer_queue_low?
    mailer_queue = Sidekiq::Queue.new("mailers")
    mailer_queue.count < 500
  rescue
    false
  end
end
