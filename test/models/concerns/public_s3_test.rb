require "test_helper"
require 'active_storage/service/s3_service'

class PublicS3Test < ActiveSupport::TestCase
  class DummyClass< ActiveRecord::Base
    include PublicS3

    has_one_public_s3 :test_file
  end

  class MockService
    def upload(a, b, c) ; end
    def url_expires_in ; end
    def url(a, b)
      'mock'
    end
  end

  setup do
    Temping.create :dummy_class
    @dummy = DummyClass.new
    # Mock out the service so we don't actually call it
    @dummy.instance_variable_set(:@service, MockService.new)
  end

  teardown do
    Temping.teardown
  end

  it 'has the correct methods to be defined on the model' do
    assert @dummy.respond_to?('test_file')
    assert @dummy.respond_to?('test_file=')
    assert @dummy.respond_to?('upload_public_test_file')
    assert @dummy.respond_to?('public_test_file_url')
    assert @dummy.respond_to?('test_file_purge_later')
    assert @dummy.respond_to?('test_file_detach')
  end

  it 'can upload a file' do
    image = Rails.root.join("app/assets/images/brave-logo.png")
    result = @dummy.upload_public_test_file(
      {
        io: open(image),
        filename: "dummy.jpg",
        content_type: "image/jpg"
      }
    )
    assert result
  end

  it 'can get the url' do
    image = Rails.root.join("app/assets/images/brave-logo.png")
    result = @dummy.upload_public_test_file(
      {
        io: open(image),
        filename: "dummy.jpg",
        content_type: "image/jpg"
      }
    )
    assert @dummy.public_test_file_url
  end
end
