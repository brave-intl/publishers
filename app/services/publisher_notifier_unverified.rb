class PublisherNotifierUnverified < BaseService
  attr_reader :notification_params, :notification_type

  PUBLISHER_TYPES = %w(youtube, domain)

  def initialize(publisher_type:, notification_params: {})
    @notification_params = (notification_params) || {}
    @publisher_type = publisher_type

    if !PUBLISHER_TYPES.include?(@publisher_type)
      raise InvalidPublisherTypeError.new("#{@publisher_type} is an invalid publisher type")
    end
  end

  def perform
    if @publisher_type == "domain"
      return perform_domain
    else
      return perform_youtube
    end
  end

  def perform_domain
    if !@notification_params.key?(:domain)
      raise InvalidPublisherTypeError.new("No domain supplied")
    end

    domain = @notification_params[:domain]
    contacts = GetWhoisEmailsForDomain.new(domain).perform

    if contacts.empty?
      raise NoEmailsFoundError.new("No contacts listed on whois info for '#{domain}'")
    end

    # store all distinct valid contact emails available
    emails = Array.new
    contacts.each do |contact|
      email = contact.email
      if emails.exclude?(email) && is_valid_email?(email)
        emails.push(email)
      end
    end

    if emails.empty?
      raise NoEmailsFoundError.new("No valid emails found on whois info for '#{domain}'")
    end

    # send notification to valid emails
    emails.each do |email|
      PublisherMailer.unverified_domain_reached_threshold(domain, email).deliver_later
      PublisherMailer.unverified_domain_reached_threshold_internal(domain, email).deliver_later
    end
  end

  def perform_youtube
    # TO DO
  end

  class InvalidPublisherTypeError < RuntimeError; end
  class NoEmailsFoundError < RuntimeError; end

  private

  def is_valid_email?(email)
    (email =~ Devise.email_regexp) != nil
  end
end