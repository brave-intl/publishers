module CsrfGetter
  def get_csrf_token
    get api_nextv1_home_dashboard_path
    assert_response :success

    # "CSRF-TOKEN=5Jtjrf2LbEcvbC6KmkrUoz0ovZAAo3KcT2pdKXL7KmRe1CtK6oXqnN4bkKBdld0-QpiJJaek47EnW0ElleYrdw;"
    cookie_string = @response.headers["set-cookie"][0].split(" ")[0]
    match = cookie_string.match(/CSRF-TOKEN=([^;]+)/)
    match ? match[1] : nil
  end
end
