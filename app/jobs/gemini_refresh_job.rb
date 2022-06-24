class GeminiRefreshJob < Oauth2BatchRefreshJob
  private

  def set_klass
    GeminiConnection
  end
end
