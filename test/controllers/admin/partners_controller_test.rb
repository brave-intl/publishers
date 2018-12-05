require 'test_helper'
require "shared/mailer_test_helper"
require "webmock/minitest"

class Admin::PartnersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper


  before do
    admin = publishers(:admin)
    sign_in admin
    @partner_id = publishers(:partner).id
  end

  after do
    clear_enqueued_jobs
  end

  describe "index" do
    describe "when users does not search" do
      it 'assigns @partners' do
        get admin_partners_path
        assert controller.instance_variable_get("@partners")
      end
    end

    describe "when user searches" do
      describe 'when suspended' do
        it 'only shows suspended' do
          get admin_partners_path, params: { suspended: '1' }

          partners = controller.instance_variable_get("@partners")
          assert partners.count
          partners.each do |p|
            assert p.suspended?
          end
        end
      end

      describe 'created by me' do
        it 'returns the partners created by me' do
          created_by_me  = Partner.where(created_by: publishers(:admin))
          not_created_by_me  = Partner.where.not(created_by: publishers(:admin))

          get admin_partners_path, params: { created_by_me: '1' }

          partners = controller.instance_variable_get("@partners")
          assert partners.count
          partners.each do |p|
            assert created_by_me.include? p
            refute not_created_by_me.include? p
          end
        end
      end

      describe 'searching by a query' do
        it 'returns results' do
          get admin_partners_path, params: { q: 'paul' }

          partners = controller.instance_variable_get("@partners")
          assert partners.count
          partners.each do |p|
            assert p.name.downcase.include? 'paul'
          end
        end
      end
    end
  end

  describe "new" do
    it "allows admins to access partners" do
      get new_admin_partner_path
      assert controller.instance_variable_get("@partner")
      assert_response :success
    end
  end

  describe "edit" do
    it "allows admins to access partners" do
      get edit_admin_partner_path(@partner_id)
      assert controller.instance_variable_get("@partner")
      assert_response :success
    end
  end

  describe "create" do
    let(:unverified_email) { "unverified@example.com" }

    test "when there's an unverified existing publisher" do
      publisher = Publisher.find_or_create_by(pending_email: unverified_email)

      # Ensure it's a publisher
      assert_equal publisher.role, Publisher::PUBLISHER

      # Make request
      assert_enqueued_emails(1) do
        post admin_partners_path, params: { email: unverified_email, organization_name: 'The Guardian' }
      end

      # We assert that only one account is created
      assert_empty Publisher.where(email: unverified_email)
      # We made it a partner
      assert Publisher.find_by(pending_email: unverified_email).partner?
    end

    test "when there's a verified existing publisher" do
      # ensure there are no previously existing entries in the database
      Publisher.where(pending_email: unverified_email).destroy_all
      publisher = Publisher.find_or_create_by(email: unverified_email)

      # Ensure it's a publisher
      assert_equal publisher.role, Publisher::PUBLISHER

      # Make request
      assert_enqueued_emails(1) do
        post admin_partners_path, params: { email: unverified_email, organization_name: 'The Guardian' }
      end

      # We assert that only one account is created
      assert_empty Publisher.where(pending_email: unverified_email)
      # We made it a partner
      assert Publisher.find_by(email: unverified_email).partner?
    end

    test "when there's a new partner" do
      partner_email = 'partner@example.com'

      # Make request
      assert_enqueued_emails(1) do
        post admin_partners_path, params: { email: partner_email, organization_name: 'The Guardian' }
      end

      # We made it a partner
      assert Partner.find_by(email: partner_email).partner?
    end

    test "when the email is already a partner" do
      partner_email = "partner@completed.org"

      # Make request
      assert_enqueued_emails(0) do
        post admin_partners_path, params: { email: partner_email, organization_name: 'The Guardian' }
      end

      assert_equal "Email is already a partner", flash[:alert]
      assert_redirected_to new_admin_partner_path(organization: 'The Guardian')
    end

    test 'when the organization is invalid' do
      post admin_partners_path, params: { email: unverified_email, organization_name: 'not found' }
      assert_equal "The organization specified does not exist", flash[:alert]
      assert_template :new
    end
  end

  describe 'update' do
    describe 'when the organization is valid' do
      it 'updates the partner' do
        partner_id = publishers(:completed).id
        patch admin_partner_path(partner_id), params: { organization_name: 'The Guardian' }

        updated = Partner.find(partner_id)
        assert updated.organization.name = 'The Guardian'
        assert updated.partner?
      end

    end

    describe 'when the organization is not valid' do
      it 'shows edit page' do
        patch admin_partner_path(@partner_id), params: { organization_name: '' }
        assert_template :edit
        assert_response :success
      end
    end
  end
end
