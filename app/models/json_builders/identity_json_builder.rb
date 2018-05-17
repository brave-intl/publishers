class JsonBuilders::IdentityJsonBuilder
=begin
(Albert Wang). Meant for the browsers. Parity with Ledger's v3/identity.
=end

  attr_reader :channel_detail, :publisher_name, :errors

  # Copy of bat-ledger/node_modules/bat-publisher/index.js `providerRE`
  URL_REGULAR_EXPRESSION = /^([A-Za-z0-9][A-Za-z0-9-]{0,62})#([A-Za-z0-9][A-Za-z0-9-]{0,62}):(([A-Za-z0-9-._~]|%[0-9A-F]{2})+)$/


  def initialize(publisher_name:)
    @errors = []
    @publisher_name = publisher_name
    @parsed_publisher_name = URL_REGULAR_EXPRESSION.match(@publisher_name)
    find_channel_detail
  end

  def find_channel_detail
    @channel_detail = if @parsed_publisher_name.present? && @parsed_publisher_name[1] == Channel::YOUTUBE
      YoutubeChannelDetails.find_by(youtube_channel_id: @parsed_publisher_name[3])
    elsif @parsed_publisher_name.present? && @parsed_publisher_name[1] == Channel::TWITCH
      TwitchChannelDetails.find_by(twitch_channel_id: @parsed_publisher_name[3])
    else
      SiteChannelDetails.find_by(brave_publisher_id: @publisher_name)
    end
  end

  def build
    @json = if @channel_detail.nil?
      # @errors << "Channel not found"
      build_site_identity_json
    elsif @channel_detail.is_a?(YoutubeChannelDetails)
      build_youtube_identity_json
    elsif @channel_detail.is_a?(TwitchChannelDetails)
      build_twitch_identity_json
    elsif @channel_detail.is_a?(SiteChannelDetails)
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
      json.providerName   @parsed_publisher_name[1]
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
    Jbuilder.encode do |json|
      json.publisher      @publisher_name
      json.SLD            @publisher_name
      json.RLD            ''
      json.QLD            ''
      json.URL            @publisher_name
      json.properties     do
        build_properties(json)
      end
    end
  end

  def build_twitch_identity_json
    # TODO with real values
    Jbuilder.encode do |json|
      json.publisher      @publisher_name
      json.publisherType  'provider'
      json.providerName   @parsed_publisher_name[1]
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
    if @channel_detail.present? && @channel_detail.channel.verified?
      json.verified true
      json.timestamp (Time.now.to_i << 32)
    end
  end
end
