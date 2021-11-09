# typed: ignore
class AddSubscribedToMarketingEmailToPublishers < ActiveRecord::Migration[6.0]
  def change
    add_column :publishers, :subscribed_to_marketing_emails, :boolean, default: false, null: false
    remove_column :publishers, :visible
  end
end
