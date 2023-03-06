class UpholdRefreshJob < Oauth2BatchRefreshJob
  private

  def set_klass
    UpholdConnection
  end
end
