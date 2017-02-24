class PublisherLegalFormS3Getter < BaseS3Client
  S3_SIGNED_URL_TTL = 1.week

  attr_reader :publisher_legal_form

  def initialize(publisher_legal_form:)
    @publisher_legal_form = publisher_legal_form
  end

  def get_form_s3_url
    bucket.object(publisher_legal_form.s3_key).presigned_url(:get, expires_in: S3_SIGNED_URL_TTL)
  end

  def get_form_fields_s3_url
    bucket.object(publisher_legal_form.form_fields_s3_key).presigned_url(:get, expires_in: S3_SIGNED_URL_TTL)
  end
end
