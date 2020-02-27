class BrowserUser < Publisher
  default_scope { where(role: Publisher::BROWSER_USER) }
end
