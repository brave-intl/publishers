class EncryptedS3Store < BaseS3Client
  def initialize
    require "gpgme_init"
    require "lib/gpgme"
  end

  # Returns object of type GPGME::Data
  def encrypt(data)
    crypto.encrypt(data, recipients: GPG_PUBKEY_RECIPIENT)
  end

  # Returns S3::Object
  # To get the presigned URL call:
  # object.presigned_url(:get, expires_in: 1.week)
  def put_object(data:, key:)
    bucket.put_object(
      acl: "authenticated-read",
      body: encrypt(data).read,
      key: key,
    )
  end

  private

  def crypto
    @crypto ||= GPGME::Crypto.new(armor: true)
  end
end
