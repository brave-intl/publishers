# Local Vault-Promo-Services Setup

**Note: This documentation has not been reviewed for some time and may be incomplete/innaccurate.**

1. Request access to [Vault-Promo-Services](https://github.com/brave-intl/vault-promo-services) and [ip2tags](https://github.com/brave-intl/vault-promo-services)
2. Follow the [setup instructions](https://github.com/brave-intl/vault-promo-services)
3. Create and run a `vault-promo-services.sh` start script like this

```
export DATABASE_URL="services"
export PGDATABASE="services"
export AUTH_TOKEN=1234
export S3_KEY="X"
export S3_SECRET="x"
export WINIA32_DOWNLOAD_KEY="/"
export WINX64_DOWNLOAD_KEY="/"
export OSX_DOWNLOAD_KEY="/"
export TEST=1

dropdb services
createdb services
for folder in ./migrations/*; do
  psql services < ${folder}/up.sql
done
npm start
```

- If you run into an issue about a missing `.mmdb` file, run `fetch.sh` in `node_modules/ip2tags`

4. Add the following into your Publishers start script

```
export API_PROMO_BASE_URI="http://127.0.0.1:8194"
export API_PROMO_KEY="1234"
```


