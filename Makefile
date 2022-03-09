GIT_VERSION := $(shell git describe --abbrev=8 --dirty --always --tags)
GIT_COMMIT := $(shell git rev-parse --short HEAD)
BUILD_TIME := $(shell date +%s)

ci:
	bundle install
	yarn
	bundle exec bundle-audit update
	RAILS_ENV=test bundle exec rails test
	bundle exec brakeman
	bundle exec standardrb
	bundle exec rubocop --require rubocop-sorbet -c .rubocop-sorbet.yml
	bundle exec srb tc

docker:
	docker build --build-arg COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(GIT_VERSION) \
		--build-arg BUILD_TIME=$(BUILD_TIME) -t publishers:latest .
	docker tag publishers:latest publishers:$(GIT_VERSION)

docker-dev-build:
	docker-compose build

docker-dev:
	docker-compose up

docker-load-balances:
	docker-compose run web sh -c 'rails "eyeshade:create_channel_balances"'

docker-test:
	docker-compose up --detach postgres web
	docker-compose run -e "RAILS_ENV=test" web sh -c "./scripts/entrypoint.sh && rails test && yarn test"
	docker-compose down

k8:
	kubectl delete -f web-deployment.yaml
	kubectl delete services publishers
	kubectl apply -f  web-deployment.yaml
	kubectl rollout status deployment.v1.apps/publishers
	kubectl expose deployment publishers --type=NodePort --port=3000
	kubectl get pods
	minikube service publishers --url
