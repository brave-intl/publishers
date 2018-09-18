class Admin::DashboardController < AdminController
  def index
    @site = Piwik::Site.load(6)
    @seo_info = @site.seo_info
    @visits = getVisits()
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

  def getVisits()
    query = Piwik::VisitsSummary.getVisits(:idSite => 6, :period => :month, :date => :last12)
    return query.result.to_json
  end

end
