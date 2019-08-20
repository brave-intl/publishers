module ApplicationHelper
  def popover_menu(&block)
    render(layout: "popover", &block)
  end

  def piwik_domain
    piwik_domain = ""
    begin
      host = URI.parse(request.original_url).host
      domain = "#{PublicSuffix.parse(host).domain}"
      piwik_domain = "#{Rails.application.secrets[:piwik_host_prefix]}.#{domain}" if domain.in?(["basicattentiontoken.org", "brave.com"])
    rescue
    end
    piwik_domain
  end
end
