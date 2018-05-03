require 'sendgrid-ruby'
require 'send_grid/api_helper'

# Registers each email address with SendGrid
class SendGridRegistrar < BaseService

  def initialize(publisher:, prior_email: nil)
    @publisher = publisher
    @prior_email = prior_email
  end
  
  def perform
    return if Rails.application.secrets[:sendgrid_api_offline]

    register_publisher(publisher: @publisher, prior_email: @prior_email)
  end

  private

  def register_publisher(publisher:, prior_email: nil)
    if prior_email.present?
      begin
        result = SendGrid::ApiHelper.remove_contact_by_email_from_list(
            list_id:  Rails.application.secrets[:sendgrid_publishers_list_id],
            email: prior_email)
      rescue SendGrid::NotFoundError => e
      #   Ignore since the contact may not have been in the system before
      end
    end

    id = SendGrid::ApiHelper.upsert_contact(publisher: publisher)

    SendGrid::ApiHelper.add_contact_to_list(
        list_id:  Rails.application.secrets[:sendgrid_publishers_list_id],
        contact_id: id)
  end
end