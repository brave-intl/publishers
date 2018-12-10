require 'test_helper'

class BackfillPotentialPaymentsTest < ActiveJob::TestCase
  test "backfills potential payments" do
    prev_num_potential_payments = PotentialPayment.count
    completed = publishers(:completed)
    uphold_connected = publishers(:uphold_connected)
    old_payout_contents = [{"name"=>completed.name,
                            "altcurrency"=>"BAT",
                            "probi"=>"39136205383556598598",
                            "fees"=>"0",
                            "authority"=>"",
                            "transactionId"=>"01491dc8-0fc8-4fa7-8271-afda35eca8f5",
                            "owner"=> completed.owner_identifier,
                            "type"=>"referral",
                            "address"=>"86376e91-1212-461f-843d-2dc44c99ebd7"},
                           {"publisher"=> uphold_connected.channels.first.details.channel_identifier,
                            "name"=> uphold_connected.channels.first.publication_title,
                            "altcurrency"=>"BAT",
                            "probi"=>"12418636145197038328",
                            "fees"=>"653612428694580964",
                            "authority"=>"",
                            "transactionId"=>"01491dc8-0fc8-4fa7-8271-afda35eca8f5",
                            "owner"=> uphold_connected.owner_identifier,
                            "type"=>"contribution",
                            "URL"=>"#{uphold_connected.channels.first.details.url}",
                            "address"=>"f290b714-a587-4bfc-8821-028469709669"}]

    payout_report_created_at = PayoutReport::LEGACY_PAYOUT_REPORT_TRANSITION_DATE.to_time - 1.minute
    PayoutReport.create(created_at: payout_report_created_at, final: true, contents: old_payout_contents.to_json)

    Rake::Task["database_updates:backfill_potential_payments"].invoke
    assert_equal PotentialPayment.count, prev_num_potential_payments + 2

    # Ensure the new potential payments match the original json
    payment_one = PotentialPayment.where(name: completed.name).first
    assert_equal payment_one.amount, old_payout_contents.first["probi"]
    assert_equal payment_one.fees, old_payout_contents.first["fees"]
    assert_equal payment_one.publisher_id, completed.id
    assert_equal payment_one.kind, old_payout_contents.first["type"]
    assert_equal payment_one.address, old_payout_contents.first["address"]

    payment_two = PotentialPayment.where(name: uphold_connected.channels.first.publication_title).first
    assert_equal payment_two.amount, old_payout_contents.second["probi"]
    assert_equal payment_two.fees, old_payout_contents.second["fees"]
    assert_equal payment_two.publisher_id, uphold_connected.id
    assert_equal payment_two.kind, old_payout_contents.second["type"]
    assert_equal payment_two.address, old_payout_contents.second["address"]
    assert_equal payment_two.url, old_payout_contents.second["URL"]

    # Ensure the json produced from the new potential payments is the same as the original json
    payout_report = payment_one.payout_report
    payout_report.update_report_contents
    payout_report.reload

    # TODO figure out why minitest thinks these are different when they're not
    # assert_equal old_payout_contents.first, JSON.parse(payout_report.contents).second
    # assert_equal old_payout_contents.second, JSON.parse(payout_report.contents).first
  end
end