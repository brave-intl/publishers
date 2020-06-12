GIT_VERSION := $(shell git describe --abbrev=8 --dirty --always --tags)
GIT_COMMIT := $(shell git rev-parse --short HEAD)
BUILD_TIME := $(shell date +%s)

docker:
	docker build --build-arg COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(GIT_VERSION) \
		--build-arg BUILD_TIME=$(BUILD_TIME) -t publishers:latest -f ./Dockerfile.dev .
	docker tag publishers:latest publishers:$(GIT_VERSION)

docker-dev-build:
	docker-compose -f docker-compose.dev.yml build

docker-dev:
	docker-compose -f docker-compose.dev.yml up

docker-test:
	docker-compose -f docker-compose.dev.yml up --detach postgres web
	docker-compose -f docker-compose.dev.yml run -e "RAILS_ENV=test" web rails app_initializer:setup && rails test && yarn test
	docker-compose -f docker-compose.dev.yml down
