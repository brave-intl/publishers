# frozen_string_literal: true

# Take a signed permanent reference for a blob and turn it into an expiring service URL for download.
# Note: These URLs are publicly accessible. If you need to enforce access protection beyond the
# security-through-obscurity factor of the signed blob references, you'll need to implement your own
# authenticated redirection controller.
class ActiveStorage::BlobsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include Rails.application.routes.url_helpers

  before_action :authenticate

  def show
    expires_in Rails.application.config.active_storage.service_urls_expire_in
    redirect_to @blob.service_url(disposition: params[:disposition])
  end

  private

  def authenticate
    # All unauthenticated requests go back to home page
    return redirect_to root_path, flash: {  alert: I18n.t('devise.failure.unauthenticated') } unless publisher_signed_in?

    # Allow administrators to access anything
    return if current_publisher.admin?

    # Allow users to access if they uploaded the file
    attachment = @blob.attachments&.first
    return if attachment.record.uploaded_by == current_publisher

    redirect_to root_path, flash: {  alert: I18n.t('devise.failure.unauthorized') }
  end
end
