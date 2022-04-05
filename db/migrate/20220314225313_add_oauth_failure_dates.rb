class AddOAuthFailureDates < ActiveRecord::Migration[6.1]
  def change
    add_column :uphold_connections, :oauth_refresh_failed, :boolean, default: false,   null: false
    add_column :uphold_connections, :oauth_failure_email_sent, :boolean, default: false,   null: false

    add_column :gemini_connections, :oauth_refresh_failed, :boolean, default: false,   null: false
    add_column :gemini_connections, :oauth_failure_email_sent, :boolean, default: false,   null: false

    add_column :bitflyer_connections, :oauth_refresh_failed, :boolean, default: false,   null: false
    add_column :bitflyer_connections, :oauth_failure_email_sent, :boolean, default: false,   null: false
  end
end
