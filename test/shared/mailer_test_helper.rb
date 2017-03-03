module MailerTestHelper
  def assert_email_body_matches(matcher:, email:)
    if email.multipart?
      %w(text html).each do |part|
        assert_match matcher, email.send("#{part}_part").body.to_s
      end
    else
      assert_match matcher, email.body.to_s
    end
  end
end
