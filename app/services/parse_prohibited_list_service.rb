require "base64"

class ParseProhibitedListService
  # produces
  # {:addresses=>
  #   ["0x4f47bc496083c727c5fbe3ce9cdf2b0f6496270c",
  #    "18M8bJWMzWHDBMxoLqjHHAffdRy4SrzkfB",
  #    "qpf2cphc5dkuclkqur7lhj2yuqq9pk3hmukle77vhq",
  #    "qpusmp64rajses77x95g9ah825mtyyv74smwwkxhx3", etc...
  def self.perform
    result = fetch_s3_addresses

    return result if result.blank? || result[:addresses].blank?

    ServiceRun.record_success!(self)
    result
  end

  # Each object key in the bucket is an address, URL-safe base64 encoded with padding stripped.
  def self.fetch_s3_addresses(client: Aws::S3::Client.new(region: "us-west-2"), bucket: ENV["PROHIBITED_LIST_BUCKET"])
    addresses = client.list_objects_v2(bucket:).flat_map do |page|
      page.contents.filter_map { |object| decode_key(object.key) }
    end

    {addresses: addresses.uniq}
  end

  def self.decode_key(key)
    Base64.urlsafe_decode64(key).force_encoding("utf-8")
  rescue ArgumentError
    nil
  end
end
