# K0rdent UI

K0rdent UI is a user-friendly web interface designed to simplify Kubernetes cluster management for users with varying levels of expertise.

## Helm Chart Deployment

The application can be deployed using the provided Helm chart. The chart is located in the `charts/k0rdent-ui` directory.

### Prerequisites

- Kubernetes cluster
- Helm 3.x installed

## Installation

> [!IMPORTANT] These instructions already assume you have kcm installed and running. If you don't, please refer to the onboarding guide.

### Install the Chart

```sh
helm install k0rdent-ui oci://ghcr.io/k0rdent/k0rdent-ui/k0rdent-ui --version 0.1.0 -n kcm-system
```

### Enable Local Authentication

By default, the K0rdent UI does not use authentication. To enable local authentication, you need to set the following:

```sh
kubectl set env deployment/k0rdent-ui \
  BASIC_AUTH_USERNAME={USERNAME} \
  BASIC_AUTH_PASSWORD={PASSWORD} \
  ENABLE_BASIC_AUTH=true \
  SESSION_SECRET={A STRONG TOKEN} -n kcm-system
  ```

### Access the UI

Once installed, you can forward the service to access the UI:

```sh
POD=$(kubectl -n kcm-system get pods -l app.kubernetes.io/name=k0rdent-ui -o name)
kubectl -n kcm-system port-forward $POD 8080
```


app.kubernetes.io/name=k0rdent-ui

apiVersion: v1
kind: Service
metadata:
  name: k0rdent-ui-nodeport
  namespace: kcm-system
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: k0rdent-ui
  ports:
    - port: 6500         # the port clients inside the cluster can use
      targetPort: 8080   # the containerPort in your pods
      nodePort: 30080    # the port on every node (must be 30000–32767)