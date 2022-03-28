# API Setups

*Note: This documentation has not been reviewed and may be inaccurate/incomplete*

### Google API Setup

Setup a google API project:

- Login to your google account (dev), or the Brave google account (staging, production)
- Go to [https://console.developers.google.com](https://console.developers.google.com)
- Select "Create Project" then "Create" to setup a new API project
- Give the project a name such as "creators-dev"
- Select "+ Enable APIs and Services"
- Enable "Google+ API" and "YouTube Data API v3"
- Back at the console select Credentials, then select the "OAuth consent screen" sub tab
- Fill in the details. For development you need the Product name, try "Creators Dev (localhost)"
- Then Select "Create credentials", then "OAuth client ID"
  - Application type is "Web application"
  - Name is "Creators"
  - Authorized redirect URIs is `http://localhost:3000/publishers/auth/google_oauth2/callback`
  - select "Create"
- Record the Client ID and Client secret and enter them in your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` variables
- Back at the console select "Create credentials" and select API key. This will be used for youtube channel stats via the data api.
- Record the API and enter it in your `YOUTUBE_API_KEY` variable

You may need to wait up to 10 minutes for the changes to propagate.

These steps based on [directions at the omniauth-google-oauth2 gem](https://github.com/zquestz/omniauth-google-oauth2#google-api-setup).

### Twitch API Setup

Setup a twitch API project:

- Login to your Twitch account (dev), or the Brave Twitch account (staging, production)
- Go to [https://dev.twitch.tv/dashboard](https://dev.twitch.tv/dashboard)
- Make sure you first set up 2 factor auth for your twitch account
- Select "Register Your Application" under "Applications"
- Give the project a name such as "creators-dev"
- Give the app a name and application category.
- Use the redirect URI `https://localhost:3000/publishers/auth/register_twitch_channel/callback` in development.
- Use the 'Website Integration' category
- Save the app
- Once the application is created, click on "Manage" where you can view the Client ID and create the Client Secret
- Create a Client ID and secret, saving each of them.
  - Update your env to include `TWITCH_CLIENT_ID="your-app-id"`
  - Update your env to include `TWITCH_CLIENT_SECRET="your-app-secret"`

### Twitter API Setup

- Apply for a developer account at [developer.twitter.com](https://developer.twitter.com/)
- Select "Create an App"
- Give the app a name like "Brave Payments Dev"
- Make sure "Enable Sign in with Twitter" is checked
- Set the callback url to `https://localhost:3000/publishers/auth/register_twitter_channel/callback`. If it does not allow you to set `localhost`, use a place holder for now, and later add the correct callback url through apps.twitter.com instead.
- Fill in the remaining information and hit "Create"
- Navigate to your app settings -> permissions and ensure it is readonly and requests the user email
- Regenerate your Consumer API keys
- Update your env to include `TWITCH_CLIENT_ID="your-api-key"` and `TWITTER_CLIENT_SECRET="your-api-secret-key"`
- Save

### reCAPTCHA Setup

In order to test the rate limiting and captcha components you will need to setup an account with Google's
[reCAPTCHA](https://www.google.com/recaptcha/intro/android.html). Instructions can be found at the
[reCAPTCHA gem repo](https://github.com/ambethia/recaptcha#rails-installation). Add the api keys to your Env variables.


