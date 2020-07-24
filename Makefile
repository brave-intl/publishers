GIT_VERSION := $(shell git describe --abbrev=8 --dirty --always --tags)
GIT_COMMIT := $(shell git rev-parse --short HEAD)
BUILD_TIME := $(shell date +%s)

docker:
	docker build --build-arg COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(GIT_VERSION) \
		--build-arg BUILD_TIME=$(BUILD_TIME) -t publishers:latest .
	docker tag publishers:latest publishers:$(GIT_VERSION)

docker-dev-build:
	docker-compose build

docker-dev:
	docker-compose up

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
