class AddSendEmailsToUpholdConnection < ActiveRecord::Migration[6.0]
  def change
    add_column :uphold_connections, :send_emails, :datetime, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
