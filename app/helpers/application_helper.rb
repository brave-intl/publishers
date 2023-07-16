# typed: true

module ApplicationHelper
  def popover_menu(&block)
    render(layout: "popover", &block)
  end

  def piwik_domain
    host = URI.parse(request.original_url).host
    domain = PublicSuffix.parse(host).domain.to_s
    "#{Rails.configuration.pub_secrets[:piwik_host_prefix]}.#{domain}/" if domain.in?(["basicattentiontoken.org", "brave.com"])
  rescue PublicSuffix::DomainNotAllowed, Piwik::MissingConfiguration
  end
end
