# Docker Compose Network Configuration

Publishers is configured to access the local docker network of `bat-ledgers` (Eyeshade) for cases where you need direct network communication from within the docker container context itself.

To access the `bat-ledgers` via direct network interface. You will need to be running both the `publishers` and `bat-ledgers` docker compose contexts locally (i.e. execute `docker-compose up` in the root of both applicatoins)

To test that the publishers containers have direct network access to `bat-ledgers`:


1. Retrieve the container id

Run `docker ps | grep publishers-web` and retrieve the publishers container id (first value in the output) and use it to attach to the container below

1. Attach to the container

```
docker exec -it <container_id of publishers web> bash
```

1. Confirm HTTP network access

Execute simple GET against the name of the networked container (defined in the docker-compose file of the relevant application. In this case bat-legers).

```
curl eyeshade-web:3002
```

If the network is properly configured you will recieve the default healthcheck response from eyeshade "ack". You are now able to access any container in the `ledger` network, i.e. `eyeshade-web`, `eyeshade-consumer`, or `eyeshade-postgres` ([See bat-legders' docker compose file](https://github.com/brave-intl/bat-ledger/blob/master/docker-compose.yml))


