require 'sendgrid-ruby'
require 'send_grid/api_helper'

class SendGrid::DeleteEmailJob < ApplicationJob
  queue_as :default

  def perform(email:)
    begin
      contact_id = SendGrid::ApiHelper.find_contact_by_email(email: email)["id"]
      SendGrid::ApiHelper.delete_contact(contact_id: contact_id) if contact_id.present?
    rescue SendGrid::NotFoundError => e
    #   Ignore since the contact may not have been in the system before
    end
  end
end
