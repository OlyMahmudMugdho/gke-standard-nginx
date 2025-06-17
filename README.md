# Deploying NGINX on GKE with Ingress Controller

This guide demonstrates how to create a 3-node Kubernetes cluster on **Google Kubernetes Engine (GKE)**, deploy an **NGINX application**, expose it with a **Service**, and route external traffic using the **NGINX Ingress Controller** installed via **Helm**.

---

## 🧱 Prerequisites

* Google Cloud account
* `gcloud` CLI installed and authenticated
* `kubectl` and `helm` installed
* Billing is enabled on your GCP project

---

## 🛠️ Step-by-Step Setup

### 1. Set Zone Variable

```bash
export ZONE=<your-zone>
```

### 2. Enable Required Google Cloud APIs

```bash
gcloud services enable compute.googleapis.com container.googleapis.com
```

---

### 3. Create the GKE Cluster

This command creates a 3-node cluster with workload identity and the Gateway API enabled:

```bash
gcloud container clusters create nginx-cluster \
  --zone $ZONE \
  --release-channel rapid \
  --num-nodes 3 \
  --gateway-api=standard
```

---

### 4. Get Cluster Credentials

```bash
gcloud container clusters get-credentials nginx-cluster --zone $ZONE
```

---

### 5. Deploy the NGINX App

#### `nginx-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

```bash
kubectl apply -f nginx-deployment.yaml
```

---

### 6. Expose NGINX with a NodePort Service

#### `nginx-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
```

```bash
kubectl apply -f nginx-service.yaml
```

---

### 7. Install NGINX Ingress Controller using Helm

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

kubectl create namespace ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx
```

---

### 8. Create an Ingress Resource

#### `nginx-ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```

```bash
kubectl apply -f nginx-ingress.yaml
```

---

### 9. Access the Application

Get the external IP of the NGINX Ingress Controller:

```bash
kubectl get svc -n ingress-nginx
```

Example output:

```
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   34.118.232.59    34.53.62.18     80:32676/TCP,443:30550/TCP   9m6s
```

Visit:

`http://EXTERNAL-IP` 

Example:

 [http://34.53.62.18/](http://34.53.62.18/)

You should see the **default NGINX welcome page**.

---
