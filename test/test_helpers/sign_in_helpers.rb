module SignInHelpers
  include PublishersHelper

  def sign_in_through_link(publisher)
    # generate signin link for this publisher and then visit it
    PublisherTokenGenerator.new(publisher: publisher).perform
    p "^" * 1000
    p publisher_private_reauth_url(publisher: publisher)
    link = publisher_private_reauth_url(publisher: publisher)
    visit link
    assert_content page, "Sites and channels"
  end
end
