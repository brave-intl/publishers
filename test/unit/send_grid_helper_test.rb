require "test_helper"
require "send_grid/api_helper"
require 'vcr'

class SendGridHelperTest < ActiveSupport::TestCase
  before do
    VCR.insert_cassette(name, record: :new_episodes)
  end

  after do
    VCR.eject_cassette
  end

  test "can find a contact by email" do
    contact = SendGrid::ApiHelper.get_contact_by_email(email: 'alice@completed.org')

    assert_equal 'alice@completed.org', contact['email']
  end

  test "raises an exception if it can not find a contact by email" do
    assert_raises SendGrid::NotFoundError do
      contact = SendGrid::ApiHelper.get_contact_by_email(email: 'frank@completed.org')
    end
  end

  test "upserts multiple(one) contacts and returns their sendgrid ids" do
    publisher = publishers(:completed)
    ids = SendGrid::ApiHelper.upsert_contacts(publishers: [publisher])

    assert_equal ['YWxpY2VAY29tcGxldGVkLm9yZw=='], ids
  end

  test "upserts multiple(two) contacts and returns their sendgrid ids" do
    publisher1 = publishers(:completed)
    publisher2 = publishers(:google_verified)

    ids = SendGrid::ApiHelper.upsert_contacts(publishers: [publisher1, publisher2])

    assert_equal ['YWxpY2VAY29tcGxldGVkLm9yZw==', 'YWxpY2UyQHZlcmlmaWVkLm9yZw=='], ids
  end

  test "upserts one contact and returns their sendgrid id" do
    publisher = publishers(:completed)

    id = SendGrid::ApiHelper.upsert_contact(publisher: publisher)

    assert_equal 'YWxpY2VAY29tcGxldGVkLm9yZw==', id
  end

  # Note: Cassette modified to produce error
  test "upsert raises an exception if an error is returned" do
    publisher = publishers(:completed)

    exp = assert_raises SendGrid::Error do
      SendGrid::ApiHelper.upsert_contact(publisher: publisher)
    end

    assert_equal '[{"message"=>"The following parameters are not custom fields or reserved fields: [address]", "error_indices"=>[0]}]', exp.message
  end

  test "can add a contact, by email, to a list" do
    assert SendGrid::ApiHelper.add_contact_by_email_to_list(email: 'alice@completed.org', list_id: '3986776')
  end

  test "raises trying to add a contact, by email, to a missing list" do
    exp = assert_raises SendGrid::NotFoundError do
      SendGrid::ApiHelper.add_contact_by_email_to_list(email: 'alice@completed.org', list_id: '1234')
    end
    assert_equal "{\"errors\":[{\"message\":\"List ID does not exist\"}]}\n", exp.message
  end

  test "can remove a contact, by email, from a list" do
    assert SendGrid::ApiHelper.remove_contact_by_email_from_list(email: 'alice@completed.org', list_id: '3986776')
  end

  test "raises trying to remove a contact, by email, to a missing list" do
    exp = assert_raises SendGrid::NotFoundError do
      SendGrid::ApiHelper.remove_contact_by_email_from_list(email: 'alice@completed.org', list_id: '1234')
    end
    assert_equal "{\"errors\":[{\"message\":\"List ID does not exist\"}]}\n", exp.message
  end

  test "can add multiple contacts to a list" do
    publishers = Publisher.where(email: "alice@completed.org").or(Publisher.where(email: "aliceTwitch@spud.com"))
    ids = SendGrid::ApiHelper.upsert_contacts(publishers: publishers)

    assert_equal 2, ids.length
    assert SendGrid::ApiHelper.add_contacts_to_list(list_id: '3986776', contact_ids: ids)
  end
end
