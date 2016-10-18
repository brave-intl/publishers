class BaseS3Client
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

  def region
    Rails.application.secrets[:aws_region]
  end

  def s3_resource
    @s3_resource ||= begin
      require "aws-sdk"
      client = Aws::S3::Client.new(credentials: credentials, region: region)
      Aws::S3::Resource.new(client: client)
    end
  end

  def secret_key
    Rails.application.secrets[:aws_secret_access_key]
  end
end
