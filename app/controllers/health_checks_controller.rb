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
      { name: "migrations", healthy: database_migrations_updated? },
      { name: "sidekiq", healthy: sidekiq_connected? },
      { name: "sidekiq_workers", healthy: sidekiq_workers?, optional: true },
    ]
  end

  def healthy?(status)
    status.all? { |s| s[:optional] || s[:healthy] }
  end

  def cache_connected?
    Rails.cache.redis.ping == "PONG"
  rescue StandardError
    false
  end

  def database_connected?
    ApplicationRecord.connection
    ApplicationRecord.connected?
  rescue
    false
  end

  def database_migrations_updated?
    return false unless database_connected?

    !ApplicationRecord.connection.migration_context.needs_migration?
  end

  def sidekiq_connected?
    Sidekiq.redis do |r|
      res = r.ping
      res == 'PONG'
    end
  rescue
    false
  end

  def sidekiq_workers?
    return false unless sidekiq_connected?

    ps = Sidekiq::ProcessSet.new
    ps.size.positive?
  rescue
    false
  end
end
