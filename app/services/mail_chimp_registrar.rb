require "mail_chimp/api"

# Registers each email address with MailChimp
class MailChimpRegistrar < BaseService

  def initialize(publisher:, prior_email: nil)
    @publisher = publisher
    @prior_email = prior_email
  end

  def perform
    return if Rails.application.secrets[:mailchimp_api_offline]

    register_publisher(publisher: @publisher, prior_email: @prior_email)

  rescue => e
    require "sentry-raven"
    Rails.logger.error("MailChimpRegistrar #perform error: #{e}")
    Raven.capture_exception("MailChimpRegistrar #perform error: #{e}")
    nil
  end

  private

  # Creates or updates a MailChimp list member for the publisher. Interests are initialized for new members, but
  # not for existing. This allows the members to manage their interests. One implication is new interests will not
  # be set for existing publishers. If prior_email is set the prior member's interests will be copied over, and reset
  # on the prior member. This is used when updating the email address for a publisher.
  def register_publisher(publisher:, prior_email: nil)
    existing_member_response = MailChimp::Api.get_member(email: publisher.email)

    assign_interests = {}
    clear_interests = {}

    # publisher_interests are all interests in select categories
    publisher_interests = []
    Rails.application.secrets[:mailchimp_publishers_interest_category_ids].each do |category_id|
      int_results = MailChimp::Api.publishers_list.interest_categories(category_id).interests.retrieve
      publisher_interests = publisher_interests + int_results.body[:interests]
    end

    if existing_member_response
      assign_interests = existing_member_response.body[:interests]
    else
      if prior_email
        prior_member_response = MailChimp::Api.get_member(email: prior_email)
      end

      # If a prior member existed we should copy over the publishers interests, otherwise default to true
      if prior_member_response

        publisher_interests.each do |interest|
          prior_interest = prior_member_response.body[:interests][interest[:id].to_sym]

          assign_interests[interest[:id]] = prior_interest.nil? ? true : prior_interest
          clear_interests[interest[:id]] = false
        end
      else
        publisher_interests.each do |interest|
          assign_interests[interest[:id]] = true
        end
      end
    end

    merge_fields = MailChimp::Api.publisher_merge_fields(publisher: publisher)

    result = MailChimp::Api.upsert_member(email: publisher.email, merge_fields: merge_fields, interests: assign_interests)

    # clear the publisher interests on the prior member
    if prior_email && clear_interests
      MailChimp::Api.upsert_member(email: prior_email, merge_fields: merge_fields, interests: clear_interests)
    end

    result
  end
end