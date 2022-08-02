# Local Vault-Promo-Services Setup

Creators uses promo services to create promo codes for our referral program.

Some usages:

- Attach codes to new channels for top referrers
    - This is done manually in the console whenever upon request
    - Via `Promo::RegisterChannelForPromoJob`
- The referrers can see the stats via the dashboard and nightly emails
    - The admin side also will display the stats for referral codes for referrers
    - See `Promo::EmailBreakdownsService` where we hit a stats/promo services `ReferralDownload` redshift table
- Marketing can create unattached marketing codes for marketing drives
    - Marketing uses pretty much all of the unattached promo registrations admin dashboard
- Stats will call these endpoints for promo data
    - `/api/v1/stats/publishers/totals`
    - `/api/v1/public/channels/totals`


As far as the code base, here are the usages classified:

- To get a promo code to attach to a channel. See [Promo::RegisterChannelForPromoJob](https://github.com/brave-intl/publishers/blob/6d7c5299f8f68e9db5a8d11943369c490e1feed0/app/jobs/promo/register_channel_for_promo_job.rb#L1)
    - [Here](https://github.com/brave-intl/publishers/blob/8d51c942bac1ef9e1bd1bbc5d8a8e7c7b2816c65/app/services/promo/assign_promo_to_channel_service.rb#L54) we call the service with the base URL defined [here](https://github.com/brave-intl/publishers/blob/8d51c942bac1ef9e1bd1bbc5d8a8e7c7b2816c65/app/services/promo/assign_promo_to_channel_service.rb#L101) which leads ultimately to the controller in promo-services [here](https://github.com/brave-intl/vault-promo-services/blob/master/src/controllers/promo/v1/publisher.js#L104).
    - Calls `/api/1/promo/publishers`
- https://publishers.basicattentiontoken.org/admin/unattached_promo_registrations
    -  Used by Marketing to manage marketing codes and update their status
- [ChannelOwnerUpdater](https://github.com/brave-intl/publishers/blob/0aefd1117a3061b4311ec05401debeb720a07f69/app/services/promo/channel_owner_updater.rb#L3)
    - Called twice in the codebase, for when we delete a user or when a channel changes ownership
    - Calls `/api/1/promo/publishers/#{@referral_code}`
- [PeerToPeer](https://github.com/brave-intl/publishers/blob/0aefd1117a3061b4311ec05401debeb720a07f69/app/services/promo/models/peer_to_peer_registration.rb#L7)
    - No longer used. Ice it.
    - Calls `"api/2/promo/referral_code/p2p/{id}?cap={cap}"`
- reporting.rb
    - Called via `PromoClient.reporting` in [promo_registrations_controller](https://github.com/brave-intl/publishers/blob/6d7c5299f8f68e9db5a8d11943369c490e1feed0/app/controllers/publishers/promo_registrations_controller.rb#L93) and
    - [registration_stats_report_generator](https://github.com/brave-intl/publishers/blob/0aefd1117a3061b4311ec05401debeb720a07f69/app/services/promo/registration_stats_report_generator.rb#L150) for generating [referral reports ](https://github.com/brave-intl/publishers/blob/6d7c5299f8f68e9db5a8d11943369c490e1feed0/app/controllers/admin/unattached_promo_registrations_controller.rb#L52)(Vinny uses this a few times per month)
    - Calls `api/2/promo/geoStatsByReferralCode`
- owner_registrar.rb
    - We used to attach codes to creators, but not anymore. We just attach them to channels now. You can see [the original PR](https://github.com/brave-intl/publishers/pull/1589) when this was added that we call this service to attach the code to the creator. Now it's not used. That same controller these days attaches them to the channels.
    - Calls `/api/2/promo/referral_code/unattached?number=#{@number}"`
- registration_getter.rb
    - Used in switching promo codes to a different channel
    - Calls `"/api/2/promo/referral_code/channel/#{@channel.channel_id}?#{cap_params}"`
- registration_installer_type_setter.rb
    - Used to set the installer type on https://publishers.basicattentiontoken.org/admin/unattached_promo_registrations
    - Calls `"/api/2/promo/referral/installerType"`
- registration_stats_fetcher.rb
    - Exactly what is sounds like, we fetch the stats every morning to display to the user (for channels)
    - Calls `"/api/2/promo/statsByReferralCode#{query_string}"`
- unattached_registrar.rb
    - The class that creates the unattached codes in the referral service for marketing
    - Calls `"/api/2/promo/referral_code/unattached?number=#{@number}"`
- unattached_registration_status_updater.rb
    - Updates status of unattached codes
    - Calls `"/api/2/promo/referral#{query_string}"`




Read below if you wish to get promo services running locally.

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


