class Admin::DashboardController < AdminController
  def index
    site = Piwik::Site.load(6)
    @events = site.events.getCategory(idSite: 6, period: 'week', date: 1.week.ago.strftime("%Y-%m-%d")).data.to_json
    @devices_detection = site.devices_detection.getType(idSite: 6, period: 'week', date: 1.week.ago.strftime("%Y-%m-%d")).data.to_json
  end

  def fetch(type)
    render 404 and return unless valid_type?(type)
    site.send(type)
  end

  private

  def valid_type?(type)
    type.to_sym.in?([
      :events,
      :devices_detection]
    )
  end
end
