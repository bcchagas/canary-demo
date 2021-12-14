# Canary Deployments with NGINX Ingress Controller
## Overview
This repository contains all resources that are required to test the canary feature of NGINX Ingress Controller. 

## Requirements
* [Kind](https://github.com/kubernetes-sigs/kind/) for running a Kubernetes cluster
* Docker for running the Kind cluster

## Getting Started

### Canary Test Scenario

##### Create Kubernetes Cluster

The command below takes 2 actions: it creates a Kubernetes Clusters inside a docker container and deploys the Nginx Ingress Controller.

```bash
$ make step-0
```

##### Deploy production release  
Roll-out the stable version 1.0.0 to the cluster
```bash
$ make step-1
```

##### Run tests 
Execute the following commands to send n=1000 requests to the endpoint
```bash
$ ab -n 1000 -c 100 -s 60 "http://localhost/version"
$ curl -s "http://localhost/metrics" | jq '.calls'
```
If everything is working as expected, the curl command should return "1000".

##### Reset request counter  
Send GET requests to /reset endpoint to set the request counter to zero
```bash
$ curl "http://<your_URL>/reset"
```

##### Canary deployment  
Push the new software version 1.0.1 as a canary deployment to the cluster
```bash
$ make step-2
```

##### Perform tests  
Again, start sending traffic to the endpoint
```bash
$ ab -n 1000 -c 100 -s 60 "http://localhost/version"
```

##### Verify the weight split  
Do a port forward to each of the pods to check the request count
```bash
$ kubectl -n demo-prod port-forward <pod-name> 8080:8080
$ curl -s http://localhost:8080/metrics | jq '.calls'
$ kubectl -n demo-prod port-forward <pod-name> 8081:8080
$ curl -s http://localhost:8081/metrics | jq '.calls'
```
Unless the weight has been changed to a different value, you should see approximately 800 requests being served by the production deployment and the remainig 200 by the canary. 

### Delete
Remove all resource from the cluster 
```bash
$ make clean-up
```
