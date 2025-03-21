# Kubernetes OIDC Authentication Setup Guide for Okta on KinD

## Prerequisites

### Required Software

- docker
- kind
- helm
- coreutils
- jq
- jwt

### Okta Setup

- [UI Guide](https://developer.okta.com/blog/2021/10/08/secure-access-to-aws-eks#configure-your-okta-org)
- [Developer Signup](https://developer.okta.com/signup/)

## Installation Steps

### Install Krew

Follow the installation [guide](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)

### Install OIDC Login Plugin

```bash
kubectl krew update
kubectl krew install oidc-login
```

### Create StructuredAuthenticationConfiguration

Create `authentication-config.yaml`:

```yaml
apiVersion: apiserver.config.k8s.io/v1beta1
kind: AuthenticationConfiguration
jwt:
  - issuer:
      url: "https://trial-***.okta.com/oauth2/***"
      audiences:
        - 0oa***697
    claimMappings:
      username:
        claim: email
        prefix: ""
      groups:
        claim: groups
        prefix: ""
    claimValidationRules:
      - expression: "has(claims.email)"
        message: "email claim must be present"
      - expression: "claims.email != ''"
        message: "email claim must be non-empty"
      - expression: "has(claims.groups)"
        message: "groups claim must be present"
      - expression: "type(claims.groups) == list ? size(claims.groups) > 0 : true"
        message: "groups list must be non-empty"
      - expression: "type(claims.groups) == string ? claims.groups.size() > 0 : true"
        message: "groups string must be non-empty"        
    userValidationRules:
      - expression: "!user.username.startsWith('system:')"
        message: "username cannot used reserved system: prefix"
      - expression: "user.groups.all(group, !group.startsWith('system:'))"
        message: "groups cannot used reserved system: prefix"
```

### Create KinD Cluster Configuration

Create `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  "StructuredAuthenticationConfiguration": true
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: ClusterConfiguration
        apiServer:
          extraArgs:
            authentication-config: /etc/kubernetes/authentication-config.yaml
          extraVolumes:
            - name: authentication-config
              hostPath: /etc/kubernetes/authentication-config.yaml
              mountPath: /etc/kubernetes/authentication-config.yaml
              readOnly: true
              pathType: File
    extraMounts:
      - hostPath: ./authentication-config.yaml
        containerPath: /etc/kubernetes/authentication-config.yaml
        readOnly: true
```

### Cluster Management

#### Create KinD Cluster

```bash
kind create cluster --verbosity 99 --config kind-config.yaml --retain
```

#### Get API Server Pod Information

```bash
kubectl describe pod -n kube-system kube-apiserver-$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
```

#### [Debug] Control Plane State

```bash
docker exec kind-control-plane ls /var/log/containers/
docker exec kind-control-plane crictl ps
```

### Install k0rdent

```bash
helm install kcm oci://ghcr.io/k0rdent/kcm/charts/kcm --version 0.1.0 -n kcm-system --create-namespace
```

### RBAC Configuration (limited example)

Create RoleBinding (namespace-scoped):

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kcm-ns-viewer
  namespace: kcm-system
subjects:
  - kind: Group
    name: kcm-ns-viewer
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kcm-namespace-viewer-role
```

### Token Management

#### Get Okta OIDC Token

```bash
export K8S_TOKEN=$(kubectl oidc-login get-token \
  --oidc-issuer-url=https://trial-***.okta.com/oauth2/*** \
  --oidc-client-id=0oa***697 \
  --listen-address=127.0.0.1:8000 \
  --skip-open-browser=true \
  --oidc-extra-scope=email \
  --force-refresh | jq -r '.status.token' \
) && echo $K8S_TOKEN | jwt decode -
```

#### [DEBUG] Validate Token

```bash
kubectl --token=$K8S_TOKEN get secrets -n kcm-system -v=9
```

### Kubernetes Configuration

#### Set Credentials

```bash
kubectl config set-credentials user --token=$K8S_TOKEN
```

#### Set Context

```bash
kubectl config set-context user --cluster="kind-$(kind get clusters | head -1)" --user=user --namespace=kcm-system
```

#### Verify Access

```bash
kubectl --context=user auth can-i get namespaces
kubectl --context=user auth can-i get secrets -n kcm-system
kubectl --context=user auth can-i get secrets --all-namespaces
kubectl --context=user auth can-i get pods -n kcm-system
kubectl --context=user auth can-i get pods --all-namespaces
```

#### Switch Contexts to OIDC credentials

```bash
kubectl config use-context user
```

#### Switch Contexts to default credentials

```bash
kubectl config use-context "kind-$(kind get clusters | head -1)"
```

#### View Kubeconfig

```bash
kubectl config view --context=user
```

#### [DEBUG] View API Server Logs

```bash
kubectl --context="kind-$(kind get clusters | head -1)" logs -n kube-system kube-apiserver-kind-control-plane | grep authentication.go
```

#### Delete Cluster

```bash
kind delete cluster
```
