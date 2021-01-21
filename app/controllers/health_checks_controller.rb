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
    ]
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
end
