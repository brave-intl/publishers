### Adding a new type of channel

The easiest possible way to add a new channel is to find the Omniauth gem for the specified integration. A few examples include [omniauth-soundcloud](https://github.com/soundcloud/omniauth-soundcloud), [omniauth-github](https://github.com/omniauth/omniauth-github), or [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook)

1. Add the gem to the [Gemfile](https://github.com/brave-intl/publishers/blob/staging/Gemfile#L73)
2. Run bundle install
3. Run `rails generate property INTEGRATION_channel_details` (Note: replace `INTEGRATION` with the name of the integration, e.g. github, soundcloud, vimeo, etc)
4. Run `rails db:migrate`
5. Register a new route in [config/initializers/devise.rb](https://github.com/brave-intl/publishers/blob/2019_05_29/config/initializers/devise.rb#L243)
6. Add a new controller method in `app/controllers/publishers/omniauth_callbacks_controller.rb` similar to `register_github_channel` or `register_reddit_channel`
7. Add the link and icon to `/app/views/application/_choose_channel_type.html.slim`
8. Add translations in [en.yml](https://github.com/brave-intl/publishers/blob/staging/config/locales/en.yml) for `helpers.publisher.channel_type` and `helpers.publisher.channel_name`

   ```yaml
   channel_type:
     youtube: YouTube channel
     website: Website
     <INTEGRATION>: Your <INTEGRATION> Name
    channel_name:
      youtube: YouTube
      website: the website
      <INTEGRATION>: <INTEGRATION> Name
   ```

9. Add assets for the new integration. Both a [32x32 png](https://github.com/brave-intl/publishers/tree/staging/app/assets/images/publishers-home) and a [SVG of the logo](https://github.com/brave-intl/publishers/tree/staging/app/assets/images/choose-channel).

### Run Tests

Tests can be run on the container with

```sh
docker-compose run app rake test
```

Other one off commands can be run as above, but replacing `rake test`. Note this spawns a new container.

### Debugging

Debugging with byebug and pry can be done by attaching to the running process. First get the container
id with `docker ps`

```sh
docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED                  STATUS              PORTS                                            NAMES
234f116cd942        publishers_app           "foreman start --pro…"   Less than a second ago   Up 2 seconds        0.0.0.0:3000->3000/tcp                           publishers_app_1
b592d489a8d3        redis                    "docker-entrypoint.s…"   15 minutes ago           Up 3 seconds        6379/tcp                                         publishers_redis_1
f1c86172def7        schickling/mailcatcher   "mailcatcher --no-qu…"   15 minutes ago           Up 2 seconds        0.0.0.0:1025->1025/tcp, 0.0.0.0:1080->1080/tcp   publishers_mailcatcher_1
```

Then attach to the container and you will hit your `binding.pry` breakpoints

```sh
docker attach 234f116cd942
```

To connect with a bash shell on a running container use:

```sh
docker exec -i -t 234f116cd942 /bin/bash
root@234f116cd942:/var/www#
`
