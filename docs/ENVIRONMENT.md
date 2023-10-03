# Environment Variables and Configuration

Configuration is set in [config/secrets.yml](https://github.com/brave/publishers/blob/master/config/secrets.yml) via environment variables.

We use the [dotenv gem](https://github.com/bkeepers/dotenv) to load variables specified in `.env` into the rails app, only in the `development` and `test` environments. This makes sure they are only loaded for the context of the running rails app and that they don't pollute the shell environment.


