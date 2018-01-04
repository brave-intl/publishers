class PublisherNotifierUnverified < BaseService
  attr_reader :notification_params, :notification_type

  PUBLISHER_TYPES = %w(domain) # TODO: youtube

  def initialize(publisher_type:, publisher_id: )
    @publisher_id = publisher_id
    @publisher_type = publisher_type

    ensure_params_exist

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
    domain = @publisher_id
    contacts = GetWhoisEmailsForDomain.new(@domain).perform

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

  class BlankParamsError < RuntimeError; end
  class InvalidPublisherTypeError < RuntimeError; end
  class NoEmailsFoundError < RuntimeError; end

  private

  def is_valid_email?(email)
    (email =~ Devise.email_regexp) != nil
  end

  def ensure_params_exist
    if @publisher_id.blank?
      raise BlankParamsError.new("No publisher id supplied")
    end

    if @publisher_type.blank?
      raise BlankParamsError.new("No publisher type supplied")
    end
  end
end