class EncryptedS3Store
  def initialize
    require "aws-sdk"
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

  def access_key_id
    Rails.application.secrets[:aws_access_key_id]
  end

  def bucket
    @bucket ||= s3_resource.bucket(Rails.application.secrets[:aws_bucket])
  end

  def credentials
    Aws::Credentials.new(access_key_id, secret_key)
  end

  def crypto
    @crypto ||= GPGME::Crypto.new(armor: true)
  end

  def region
    Rails.application.secrets[:aws_region]
  end

  def s3_resource
    @s3_resource ||= begin
      client = Aws::S3::Client.new(credentials: credentials, region: region)
      Aws::S3::Resource.new(client: client)
    end
  end

  def secret_key
    Rails.application.secrets[:aws_secret_access_key]
  end
end
