# Preview all emails at http://localhost:3000/rails/mailers
# Preview publisher_mailer emails at http://localhost:3000/rails/mailers/publisher_mailer
class PublisherMailerPreview < ActionMailer::Preview

  def login_email
    PublisherMailer.login_email(Publisher.first)
  end

  def verify_email
    PublisherMailer.verify_email(Publisher.first)
  end

  def verification_done
    PublisherMailer.verification_done(Publisher.first)
  end

  def verification_done_internal
    PublisherMailer.verification_done_internal(Publisher.first)
  end

  def welcome
    PublisherMailer.welcome(Publisher.first)
  end

  def welcome_internal
    PublisherMailer.welcome_internal(Publisher.first)
  end

  def uphold_account_changed
    PublisherMailer.uphold_account_changed(Publisher.first)
  end

  def verified_no_wallet
    PublisherMailer.verified_no_wallet(Publisher.first, nil)
  end

  def verified_no_wallet_internal
    PublisherMailer.verified_no_wallet(Publisher.first, nil)
  end
end
