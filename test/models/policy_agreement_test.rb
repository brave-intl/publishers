require "test_helper"

class PolicyAgreementTest < ActiveSupport::TestCase
  test 'Add policy agreements to a publisher and see if the publisher has accepted' do
    publisher = publishers(:verified)
    publisher.policy_agreement.destroy
    publisher.reload
    assert_nil publisher.policy_agreement
    policy_agreement = PolicyAgreement.create(
      user_id: publisher.id,
      accepted_publisher_tos: false,
      accepted_publisher_privacy_policy: false
    )
    publisher.reload
    refute publisher.policy_agreement.accepted?

    policy_agreement_2 = PolicyAgreement.create(
      user_id: publisher.id,
      accepted_publisher_tos: false,
      accepted_publisher_privacy_policy: false
    )
    assert_nil policy_agreement_2.id

    policy_agreement.update(
      accepted_publisher_tos: true,
      accepted_publisher_privacy_policy: true
    )

    publisher.reload
    assert publisher.policy_agreement&.accepted?
  end
end
