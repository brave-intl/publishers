class UpholdRefreshJob < Oauth2BatchRefreshJob
  private

  def set_klass
    UpholdConnection
  end

  def set_limit
    20000
  end
end
