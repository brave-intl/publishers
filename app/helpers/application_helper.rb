module ApplicationHelper
  def popover_menu(&block)
    render(layout: "popover", &block)
  end

  def piwik_domain
    host = URI.parse(request.original_url).host
    domain = PublicSuffix.parse(host).domain.to_s
    if domain.in?(["basicattentiontoken.org", "brave.com"])
      piwik_domain = "#{Rails.application.secrets[:piwik_host_prefix]}.#{domain}/" 
    end
  end
