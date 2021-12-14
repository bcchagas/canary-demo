
build: dep vet build-canary
step-0: create-cluster
step-1: dry-run deploy-prod
step-2: dry-run deploy-canary

dep:
	go get github.com/Masterminds/glide
	glide install

vet: 
	go vet ./cmd/main.go

build-canary:
	go build -o ./bin/canary-demo ./cmd/main.go

create-cluster:
	kind create cluster --name canary --config=./kind.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

deploy-prod:
	kubectl apply -f ./deploy/prod-namespace.yaml
	sleep 2
	kubectl apply -f ./deploy/prod-deployment.yaml,./deploy/prod-service.yaml,./deploy/prod-ingress.yaml  

deploy-canary: 
	kubectl apply -f ./deploy/canary-namespace.yaml
	sleep 2
	kubectl apply -f ./deploy/canary-deployment.yaml,./deploy/canary-service.yaml,./deploy/canary-ingress.yaml  

dry-run:
	kubectl apply -f ./deploy/. --dry-run

clean-up:
	kind delete cluster --name canary

