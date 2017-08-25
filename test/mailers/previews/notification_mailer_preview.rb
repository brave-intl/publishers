# Preview all emails at http://localhost:3000/rails/mailers
# Preview notification_mailer emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  def publisher_form_retry
    NotificationMailer.publisher_form_retry(Publisher.first)
  end

  def publisher_form_retry_internal
    NotificationMailer.publisher_form_retry_internal(Publisher.first)
  end

  def publisher_payments_activated
    NotificationMailer.publisher_payments_activated(Publisher.first)
  end

  def publisher_payments_activated_internal
    NotificationMailer.publisher_payments_activated_internal(Publisher.first)
  end
end
