class AddUsesStripeForPayoutToPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :publishers, :uses_stripe_for_payout, :boolean, default: false
  end
end
