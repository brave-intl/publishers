class Cache::BrowserChannels::PrefixList
  include Sidekiq::Worker

  # Might need to adjust the value based on 
  PREFIX_LENGTH = 9

  def perform(details_type: nil)
    result = ActiveRecord::Base.connection.execute("SELECT SUBSTRING(sha2_base16, 1, #{PREFIX_LENGTH}) FROM site_banner_lookups").map { |r| r['substring'] }.to_json
    require 'brotli'
    prefix_list = PrefixList.find_or_initialize_by(name: PrefixList::ALL_CHANNELS)
    temp_file = Tempfile.new(["all_channels", ".br"])
    info = Brotli.deflate(result)
    File.open(temp_file.path, 'wb') do |f|
      f.write(info)
    end
    prefix_list.upload_public_prefix_list(
      {
        io: open(temp_file.path),
        filename: "all_channels.br",
        content_type: "br",
      },
      key: "all_channels"
    )
    prefix_list.save
  end
end
