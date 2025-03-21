# Kubernetes OIDC Authentication with Microsoft Entra ID

## Overview

This guide provides a step-by-step process to configure OIDC authentication for Kubernetes using Microsoft Entra ID. It assumes that an Entra ID application is already set up with the necessary OIDC configurations.

## Prerequisites

Before proceeding, ensure that the following are already configured in Microsoft Entra ID:

- An OIDC-enabled application registration with the appropriate redirect URIs (we will be using `http://localhost:8000` for this guide).
- Users assigned to an Entra ID group that will be used for Kubernetes authentication.
- The OIDC application should return email, groups, and profile claims.

### Required Tools

Ensure that you have the following installed:

- Docker (For running KinD clusters)
- KinD (Kubernetes in Docker)
- Helm (Package manager for Kubernetes)
- jq (For parsing JSON output)
- jwt (JWT parsing utility)
- kubectl krew (Kubectl plugin manager)
- kubectl oidc-login plugin
  - Install using krew: `kubectl krew install oidc-login`
  - Verify installation: `kubectl oidc-login version`

## Configuration Files

### Authentication Configuration File

Save the following as authentication-config.yaml:

```yaml
apiVersion: apiserver.config.k8s.io/v1beta1
kind: AuthenticationConfiguration
jwt:
  - issuer:
      url: "https://login.microsoftonline.com/<tenant-id>/v2.0"
      audiences:
        - "<client-id>"
    claimMappings:
      username:
        claim: preferred_username  # Matches the Entra ID username
        prefix: ""
      groups:
        claim: groups
        prefix: ""
    claimValidationRules:
      - expression: "has(claims.preferred_username)"
        message: "preferred_username claim must be present"
      - expression: "claims.preferred_username != ''"
        message: "preferred_username claim must be non-empty"
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

Note:

- Replace `<tenant-id>` and `<client-id>` with the appropriate values from your Entra ID application registration.
- `preferred_username` is used as the username claim because some Entra ID configurations may not return "email". If your token does not contain `preferred_username`, update this value to `email` or `upn`.

### KinD Cluster Configuration File

Save the following as kind-config.yaml:

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
    extraMounts:
      - hostPath: ./authentication-config.yaml
        containerPath: /etc/kubernetes/authentication-config.yaml
        readOnly: true
```

### RBAC Configuration File

Save the following as rbac-config.yaml:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kcm-ns-viewer
  namespace: kcm-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kcm-namespace-viewer-role
subjects:
  - kind: Group
    name: "<group-id-from-token>"
    apiGroup: rbac.authorization.k8s.io
```

Replace `<group-id-from-token>` with the group ID from the Entra ID token.

## Steps

### Step 1: Create a KinD Cluster

Create a KinD cluster using the configuration file:

```bash
kind create cluster --config kind-config.yaml
```

Verify that the cluster is running:

```bash
kubectl cluster-info
```

### Step 2: Deploy k0rdent

Deploy k0rdent to the cluster using Helm:

```bash
helm install kcm oci://ghcr.io/k0rdent/kcm/charts/kcm --version 0.1.0 -n kcm-system --create-namespace
```

Verify k0rdent is running:

```bash
kubectl get pods -n kcm-system
```

### Step 3: Apply RBAC Configuration

Apply the RBAC configuration to grant access to the Entra ID group:

```bash
kubectl apply -f rbac-config.yaml
```

Verify that the role binding is created:

```bash
kubectl get rolebinding -n kcm-system
```

This RoleBinding grants the `kcm-ns-viewer` group read-only access to the `kcm-system` namespace. It uses the `kcm-namespace-viewer-role` ClusterRole (baked into the k0rdent installation) to define the permissions.

### Step 4: Authenticate using OIDC

Retrieve the OIDC token:

```bash
export K8S_TOKEN=$(kubectl oidc-login get-token \
  --oidc-issuer-url=https://login.microsoftonline.com/<tenant-id>/v2.0 \
  --oidc-client-id=<client-id> \
  --oidc-client-secret=<client-secret> \
  --oidc-redirect-url-hostname=localhost \
  --listen-address=localhost:8000 \
  --skip-open-browser=true \
  --oidc-extra-scope="email profile openid" \
  --force-refresh | jq -r '.status.token')
```

Note:

- Replace `<tenant-id>`, `<client-id>`, and `<client-secret>` with the appropriate values from your Entra ID application registration.
- The `--oidc-redirect-url-hostname` should match the redirect URI configured in the Entra ID application registration.
- The `email profile openid` scopes ensure that the token contains user identity claims. Without these, the token may not include the expected "groups" or "preferred_username".

Verify that the token contains the necessary claims (email, groups, profile).

```bash
echo $K8S_TOKEN | jwt decode -
```

## Verification Steps

### Verify Access to the Cluster

Configure the Kubernetes context to use the OIDC token:

```bash
kubectl config set-credentials oidc-user --token=$K8S_TOKEN
kubectl config set-context oidc-context --cluster=kind-kind --user=oidc-user
kubectl config use-context oidc-context
```

To switch back to the default context, use:

```bash
kubectl config use-context "kind-$(kind get clusters | head -n1)" 
```

### Verify RBAC Permissions

Use the kubectl auth can-i command to verify permissions:

```bash
kubectl auth can-i list secrets -n kcm-system
# yes
kubectl auth can-i create secrets -n kcm-system
# no
kubectl auth can-i list secrets -n kube-public
# no
```

Based on the RBAC configuration, the user should have read-only access to the `kcm-system` namespace and no access to the `kube-public` namespace.

We can also verify this by listing the secrets in the namespaces:

```bash
kubectl get secrets -n kcm-system
kubectl get secrets -n kube-public  # Expected to fail
```

## Conclusion

This guide has demonstrated how to configure OIDC authentication for Kubernetes using Microsoft Entra ID. By following the steps outlined, you can set up OIDC authentication for your Kubernetes cluster and grant access based on Entra ID group membership.