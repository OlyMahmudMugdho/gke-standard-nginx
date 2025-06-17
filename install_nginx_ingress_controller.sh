#!/bin/bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Create a namespace
kubectl create namespace ingress-nginx

# Install
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx
