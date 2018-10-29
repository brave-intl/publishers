class Admin::DashboardController < AdminController
  def index
    @site = Piwik::Site.load(6)
    @seo_info = @site.seo_info
  end

  def fetch(type)
    render 404 and return unless valid_type?(type)
    site.send(type)
  end

  private

  def valid_type?(type)
    type.to_sym.in?([
      :events,
      :visits,
      :devices_detection]
    )
  end

end
