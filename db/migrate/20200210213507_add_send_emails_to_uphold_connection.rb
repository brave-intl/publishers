class AddSendEmailsToUpholdConnection < ActiveRecord::Migration[6.0]
  def change
    add_column :uphold_connections, :send_emails, :datetime
  end

  # If send_emails is blank then the user has opted out
  UpholdConnection.update(send_emails: DateTime.now)
end
