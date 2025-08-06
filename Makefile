GIT_VERSION := $(shell git describe --abbrev=8 --dirty --always --tags)
GIT_COMMIT := $(shell git rev-parse --short HEAD)
BUILD_TIME := $(shell date +%s)
CONTAINER_ID := $(shell docker ps | grep publishers | grep web | awk '{print $$1}')
EMAIL=

default: certs build reload-db all

certs:
	bin/ssl-gen

build:
	docker-compose build

all:
	docker-compose up

admin:
	if [ -z $(EMAIL) ]; then\
		echo "No email passed to command";\
	else\
		docker exec -it $(CONTAINER_ID) rake create_admin_user["$(EMAIL)"];\
	fi\

docker-shell:
	docker exec -it $(CONTAINER_ID) bash

reload-db:
	docker-compose run web sh -c 'rake db:reset; rake db:fixtures:load; RAILS_ENV=test rake db:reset'

#### Everything from here needs review.  These commands may be in use or may simply be convenience methods.
ci:
	bundle install
	yarn
	bundle exec bundle-audit update
	RAILS_ENV=test bundle exec rails test
	bundle exec brakeman
	bundle exec standardrb

docker:
	docker build --build-arg COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(GIT_VERSION) \
		--build-arg BUILD_TIME=$(BUILD_TIME) -t publishers:latest .
	docker tag publishers:latest publishers:$(GIT_VERSION)

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
