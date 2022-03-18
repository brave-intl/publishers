# Eyeshade

Eyeshade is a javascript web application that serves as the primary accounting service for brave.  It is available in the github repository [bat-ledger](https://github.com/brave-intl/bat-ledger)
Eyeshade is a core service for Brave Creators as it provides all financial/cryptocurrency transaction data for individual publishers.  Developing on Brave Creators requires a minimal understanding of `bat-ledger` and how to integrate with it.

## Configuration

1. Follow the [setup instructions](https://github.com/brave-intl/bat-ledger) for bat-ledger
2. `make eyeshade-integration` To run publishers docker containers with the proper environment variables and network configuration to interact with bat-ledgers
3. `make eyeshade-balances` To Populate eyeshade with balances matching the fixture channels founds in the local database.  This ensures that you are dealing with actual data coming from eyeshade when interacting with the Creators Dashboard.

Balance data should be visible in the Creators Dashboard.

To stop using Eyeshade just execute `docker-compose stop` and `make all` to use the isolated network configuration.
