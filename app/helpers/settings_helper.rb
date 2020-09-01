module SettingsHelper
  def snoozed_for_year?(publisher)
    uphold_connection = publisher.uphold_connection
    return true if uphold_connection.blank? || uphold_connection.send_emails.blank?

    uphold_connection.send_emails > DateTime.now
  end

  def snoozed_forever?(publisher)
    uphold_connection = publisher.uphold_connection
    return true if uphold_connection.blank? || uphold_connection.send_emails.blank?

    uphold_connection.send_emails == UpholdConnection::FOREVER_DATE
  end
end
