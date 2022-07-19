# typed: false
require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class Admin::Publishers::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  include Devise::Test::IntegrationHelpers

  before do
    admin = publishers(:admin)
    sign_in admin
  end

  describe "#upload" do
    let(:publisher) { publishers(:completed) }
    let(:file) { fixture_file_upload(Rails.root.join("test", "fixtures", "1x1.png")) }
    let(:invoice) { @invoice ||= Invoice.create(publisher: publisher, date: "2019-01-01") }

    let(:subject) do
      post admin_publisher_invoice_upload_path(publisher_id: "_", invoice_id: invoice.id),
        params: {file: file},
        headers: {'content-type': "multipart/form-data"}
    end

    describe "when the file exists" do
      it "redirects and alerts" do
        subject
        assert_redirected_to admin_publisher_invoice_path(publisher_id: "_", id: invoice.id)
        assert_equal "Your document was uploaded successfully", flash[:notice]
      end

      it "sends an email to the user" do
        perform_enqueued_jobs do
          subject
          refute ActionMailer::Base.deliveries.empty?
        end

        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, I18n.t("partner_mailer.invoice_file_added.subject")
      end
    end

    describe "when file doesn't exist" do
      let(:subject) do
        post admin_publisher_invoice_upload_path(publisher_id: "_", invoice_id: invoice.id),
          params: {file: []},
          headers: {'content-type': "multipart/form-data"}
      end

      it "redirects and sends an error message " do
        subject
        assert_redirected_to admin_publisher_invoice_path(publisher_id: "_", id: invoice.id)
        assert_equal "Your document could not be uploaded", flash[:alert]
      end
    end
  end
end
