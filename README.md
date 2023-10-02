# Creators

Creators powers the <https://creators.brave.com> platform and enables content creators to be tipped from Brave users using the [Brave Rewards](https://brave.com/brave-rewards/) system.

It allows a creator to connect channels where they are hosted content as well as a wallet through which we deposit auto-contribute suggestions.

The ledger for current creator balance is stored in [bat-ledger](https://github.com/brave-intl/bat-ledger), also known as eyeshade.

Creators is powered by Ruby on Rails and React.

## Getting Started :wrench: Setup

Development with Docker and `docker-compose` is recommended for anyone just getting started.  If for any reason you wish to run the stack locally see [Local Installation Instructions](docs/LOCAL.md). Creators has a complex set of interactions however and has another application ([Eyeshade](https://github.com/brave-intl/bat-ledger)) as a core integration/service dependency that is most readily accessed via `docker-compose`.

## Running locally with Overmind

If you don't want to use docker, and want to develop locally, you can use [overmind](https://github.com/DarthSim/overmind):

Make sure to install it and then run:
`overmind start -N -f Procfile.dev`

## Running locally with docker-compose

1. [install docker and docker compose](https://docs.docker.com/compose/install/).
1. Ensure `openssl` is installed. `brew install openssl`
1. In your browser, navigate to `brave://flags`.  Make sure `Allow invalid certificates for resources loaded from localhost.
` is enabled.
1. Run `make`
1. Create an admin user. `make admin EMAIL="email@example.com"`

If for any reason some step in the command chain breaks, simply review the [Makefile](Makefile) and execute each command utilized by `Makefile:default`individually.

---

## The critical pieces

- [Understanding and Configuring Eyeshade](docs/EYESHADE.md)
- [Contributing to Brave Creators](docs/CONTRIBUTING.md)
- [Linting](docs/LINTING.md)
- [Service Diagram](docs/creators-diagram.png)
- [Creators Interaction with Promo Services](docs/PROMO.md)

## The advanced pieces

- [Environment Variables (Docker should handle most of this)](docs/ENVIRONMENT.md)
- [Docker Network Configuration(Informational)](docs/NETWORKS.md)
- [Creating a new Channel](docs/CHANNELS.md)
- [Configuring 3rd Party APIs (Optional)](docs/API.md)
- [Configuring Vault Promo Services (Optional)](docs/PROMO.md)
- [Generating Referral Charts](docs/CHARTS.md)

## Gotchas

### Feature Flags

When logging in as a creator, you may need to enable feature flags on that creator's account to be able to access the full set of UI options on the site.  Feature flags are stored as a json object on the Publisher model.  To update the flags for a user, run something like:

```
make docker-shell
bundle exec rails c
p = Publisher.where(email: 'gemini@completed.org').first
p.update!({ feature_flags: {"gemini_enabled"=>true, "bitflyer_enabled"=>true, "promo_lockout_time"=>"2020-11-23", "referral_kyc_required"=>true}})
```

### Gemfile

If however, you are developing on an M1 using docker-compose and find yourself in the position of needing to update a dependency/Gemfile, you are going to run into a wall.  Several gems (including Sorbet) are installed conditionally based on the chipset of the device.  Thus, your local development Gemfile will be different from what is run in CI/CD and Sorbet is required for builds.  Unfortunately for the moment the only way to properly update the Gemfile is to either install locally or to use an device that is using an x86 chipset.

You may also need to install automake and libtools before running bundle install because of the eth gem, and libsodium for the rbnacl gem:
```
$ brew install automake
$ autoreconf -i
$ brew install libtool
$ brew install libsodium
```

## Errata

- [Legacy Docs](docs/LEGACY.md) - Preserved content that requires review/updates
