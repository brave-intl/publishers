class BrowserUser < Publisher
  default_scope { where(role: Publisher::BROWSER_USER) }

  def timeout_in
    180.days
  end
end
