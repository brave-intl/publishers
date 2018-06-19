class JsonBuilders::IdentityJsonBuilder
=begin
(Albert Wang). Meant for the browsers. Parity with Ledger's v3/identity.
=end

  attr_reader :channel_detail, :publisher_name, :errors

  # Copy of bat-ledger/node_modules/bat-publisher/index.js `providerRE`
  URL_REGULAR_EXPRESSION = /^([A-Za-z0-9][A-Za-z0-9]{0,62})#([A-Za-z0-9][A-Za-z0-9]{0,62}):(([A-Za-z0-9\-._~]|%[0-9A-F]{2})+)$/


  def initialize(publisher_name:)
    @errors = []
    @publisher_name = publisher_name
    @parsed_publisher_name = URL_REGULAR_EXPRESSION.match(@publisher_name)
  end

  def find_channel_detail
    channel_detail = if @parsed_publisher_name.present? && @parsed_publisher_name[1] == Channel::YOUTUBE
      YoutubeChannelDetails.find_by(youtube_channel_id: @parsed_publisher_name[3])
    elsif @parsed_publisher_name.present? && @parsed_publisher_name[1] == Channel::TWITCH
      find_twitch_channel_detail
    else
      SiteChannelDetails.find_by(brave_publisher_id: @publisher_name)
    end
  end

  def find_twitch_channel_detail
    twitch_channel_details = TwitchChannelDetails.where(
      "twitch_channel_id = :parsed_twitch_suffix OR name = :parsed_twitch_suffix",
      {parsed_twitch_suffix: @parsed_publisher_name[3]}
    )

    if twitch_channel_details.count > 1
      LogException.perform(StandardError.new("Multiple twitch channels found"), params: { parsed_twitch_parameter: @parsed_publisher_name[3] })
    end

    twitch_channel_details.first
  end

  def build
    @json = if @parsed_publisher_name.present? && @parsed_publisher_name[1] == Channel::YOUTUBE
      build_youtube_identity_json
    elsif @parsed_publisher_name.present? && @parsed_publisher_name[1] == Channel::TWITCH
      build_twitch_identity_json
    else
      build_site_identity_json
    end
    self
  end

  def result
    @json
  end

  def build_youtube_identity_json
    Jbuilder.encode do |json|
      json.publisher      @publisher_name
      json.publisherType  'provider'
      json.providerName   Channel::YOUTUBE
      json.providerSuffix @parsed_publisher_name[2]
      json.providerValue  @parsed_publisher_name[3]
      json.URL            "https://youtube.com/#{@parsed_publisher_name[2]}/#{@parsed_publisher_name[3]}"
      json.TLD            @publisher_name.split(':')[0]
      json.SLD            @publisher_name
      json.RLD            @parsed_publisher_name[3]
      json.QLD            ''
      json.properties     do
        build_properties(json)
      end
    end
  end

  def build_site_identity_json
    public_suffix = PublicSuffix.parse(@publisher_name)
    Jbuilder.encode do |json|
      json.publisher      public_suffix.sld + '.' + public_suffix.tld
      json.SLD            public_suffix.sld + '.' + public_suffix.tld
      json.RLD            public_suffix.trd || ""
      json.QLD            public_suffix.trd.try(:split, '.').try(:last) || ""
      json.URL            @publisher_name
      json.properties     do
        build_properties(json)
      end
    end
  end

  def build_twitch_identity_json
    Jbuilder.encode do |json|
      json.publisher      @publisher_name
      json.publisherType  'provider'
      json.providerName   Channel::TWITCH
      json.providerSuffix @parsed_publisher_name[2]
      json.providerValue  @parsed_publisher_name[3]
      json.TLD            @publisher_name.split(':')[0]
      json.SLD            @publisher_name
      json.RLD            @parsed_publisher_name[3]
      json.QLD            ''
      json.properties     do
        build_properties(json)
      end
    end
  end

  def build_properties(json)
    require 'publishers/excluded_channels'

    channel_detail = find_channel_detail

    if channel_detail.present? && channel_detail.channel.present?
=begin
      (Albert Wang): To satisfy backwards compatibility in Ledger's v3.identity
      which erroneously uses Bson.timestamp().
=end
      json.timestamp (channel_detail.channel.updated_at.to_i << 32).to_s
      if channel_detail.channel.verified?
        json.verified true
      end
    end

    if channel_detail.present?
      if Publishers::ExcludedChannels.excluded?(channel_detail)
        json.exclude true
      end
    elsif @parsed_publisher_name.nil?
      public_suffix = PublicSuffix.parse(@publisher_name)
      if Publishers::ExcludedChannels.excluded_brave_publisher_id?(public_suffix.sld + '.' + public_suffix.tld)
        json.exclude true
      end
    end
  end
end
