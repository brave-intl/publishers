module SignInHelpers
  include PublishersHelper

  def sign_in_through_link(publisher)
    # generate signin link for this publisher and then visit it
    PublisherTokenGenerator.new(publisher: publisher).perform
    link = publisher_private_reauth_url(publisher: publisher)
    visit link
    assert_content page, "Account details"
  end
end
