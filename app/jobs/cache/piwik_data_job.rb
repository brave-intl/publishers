class Cache::PiwikDataJob < ApplicationJob
  queue_as :transactional

  PIWIK_VISITS_SUMMARY = "piwikVisitsSummary".freeze
  PIWIK_EVENTS_CATEGORY = "piwikEventsCategory".freeze
  PIWIK_DEVICES_DETECTION_TYPE = "piwikDevicesDetectionType".freeze
  PIWIK_DEVICES_DETECTION_BROWSER_VERSIONS= "piwikDevicesDetectionBrowserVersions".freeze
  SEO_INFO = "seo_info".freeze
  PIWIK_CACHE_LAST_UPDATED = "piwik_cache_last_updated".freeze

  def perform
    site = Piwik::Site.load(6)
    Rails.cache.write(SEO_INFO, site.seo_info.data)
    Rails.cache.write(PIWIK_VISITS_SUMMARY, site.visits.getVisits(:idSite => 6, :period => :month, :date => :last12).result.to_json)
    Rails.cache.write(PIWIK_EVENTS_CATEGORY, site.events.getCategory(idSite: 6, period: 'week', date: 1.week.ago.strftime("%Y-%m-%d")).data.to_json)
    Rails.cache.write(PIWIK_DEVICES_DETECTION_TYPE, site.devices_detection.getType(idSite: 6, period: 'week', date: 1.week.ago.strftime("%Y-%m-%d")).data.to_json)
    Rails.cache.write(PIWIK_DEVICES_DETECTION_BROWSER_VERSIONS, site.devices_detection.getBrowserVersions(idSite: 6, period: 'week', date: 1.week.ago.strftime("%Y-%m-%d")).data.to_json)
    Rails.cache.write(PIWIK_CACHE_LAST_UPDATED, Time.now)
  end
end
