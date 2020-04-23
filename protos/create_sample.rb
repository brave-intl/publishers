# TODO: Delete this file

class CreateSample
  def get_channel_response(value)
    if value == "wallet_connected"
      2
    elsif value == 'publisher_verified'
      1
    else
      0
    end
  end

  def get_site_banner_details(value)
    sd = ChannelResponses::SiteBannerDetails.new
    begin
      sd.title = value.dig("title").encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue
    end
    begin
      sd.description = value.dig("description").encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue
    end
    begin
      sd.background_url = value.dig("backgroundUrl").gsub("https://rewards-stg.bravesoftware.com/", "").encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue
    end
    begin
      sd.logo_url = value.dig("logoUrl").gsub("https://rewards-stg.bravesoftware.com/", "").encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue
    end
    begin
      sd.donation_amounts = value.dig("donationAmounts")
    rescue
    end
    begin
      sd.social_links_youtube = value.fetch["socialLinks"]["youtube"].encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue
    end
    begin
      sd.social_links_twitch = value["socialLinks"]['twitch'].encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue
    end
    begin
      sd.social_links_twitter = value["socialLinks"]['twitter'].encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue
    end
    sd
  end

  def run
    crs = ChannelResponses::ChannelResponses.new

    fo = File.open("./protos/v3_channel_responses.csv", 'r')
    fo.readlines.each do |line|
      arr = JSON.parse(line.strip)
      cr = ChannelResponses::ChannelResponse.new
      cr.channel_identifier = arr[0].encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      cr.wallet_connected_state = get_channel_response(arr[1])
      cr.wallet_address = arr[3].encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      cr.site_banner_details = get_site_banner_details(arr[4])
      crs.channel_response.push(cr)
    end
    p "encoding json"

    json =  ChannelResponses::ChannelResponses.encode_json(crs)
    File.open("./protos/v3_channel_responses.proto_json", 'w') do |f|
      f.write(json)
    end
    p "encoding binary"

    encoded = ChannelResponses::ChannelResponses.encode(crs).encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    File.write("./protos/v3_channel_responses.proto_encoded", encoded)
    p "done encoding"
  end
end
