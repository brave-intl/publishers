class BitflyerRefreshJob < Oauth2BatchRefreshJob
  private

  def set_klass
    BitflyerConnection
  end
end
