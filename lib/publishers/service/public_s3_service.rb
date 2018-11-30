module Publishers
  class Service::PublicS3Service < ActiveStorage::Service::S3Service
    attr_reader :client, :bucket, :upload_options

    def initialize

      @client = Aws::S3::Resource.new(**
        {
          :access_key_id=> ENV['S3_REWARDS_ACCESS_KEY_ID='],
          :secret_access_key=> ENV['S3_REWARDS_SECRET_ACCESS_KEY='],
          :region=>"us-east-2"
        }
      )
      @bucket = @client.bucket('rewards-stg')

      @upload_options = {}
    end
  end
end
