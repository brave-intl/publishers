require 'digest'

module MailChimp
  class Api
    def self.get_lists
      gibbon_request.lists.retrieve
    end

    def self.upsert_member(email:, merge_fields:, interests:, status_if_new: "subscribed")
      email_md5 = md5_hashed_email_address(email)

      body = {
          email_address: email,
          status_if_new: status_if_new
      }

      body[:merge_fields] = merge_fields if merge_fields.is_a?(Hash) && merge_fields.length > 0
      body[:interests] = interests if interests.is_a?(Hash) && interests.length > 0

      publishers_list.members(email_md5).upsert(body: body)
    end

    def self.get_member(email:)
      email_md5 = md5_hashed_email_address(email)
      publishers_list.members(email_md5).retrieve
    rescue Gibbon::MailChimpError => e
      if e.status_code == 404
        return nil
      else
        raise e
      end
    end

    def self.publisher_merge_fields(publisher:)
      merge_fields = {}
      merge_fields[:NAME] = publisher.name unless publisher.name.blank?
      merge_fields[:PHONE] = publisher.phone_normalized unless publisher.phone_normalized.blank?
      merge_fields
    end

    private
    def self.publishers_list
      gibbon_request.lists(Rails.application.secrets[:mailchimp_publishers_list_id])
    end

    def self.publishers_interest_category
      publishers_list.interest_categories(Rails.application.secrets[:mailchimp_publishers_interest_category_id])
    end

    def self.gibbon_request
      Gibbon::Request.new(api_key: Rails.application.secrets[:mailchimp_api_key],
                          debug: Rails.application.secrets[:mailchimp_api_debug],
                          symbolize_keys: true)
    end

    def self.md5_hashed_email_address(email)
      md5 = Digest::MD5.new
      md5 << email.downcase
      md5
    end
  end
end
