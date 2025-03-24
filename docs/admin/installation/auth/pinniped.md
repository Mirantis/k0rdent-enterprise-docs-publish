# Pinniped

This section explains how to configure {{{ docsVersionInfo.k0rdentName }}} to use the [Pinniped0(https://pinniped.dev/) components as an OIDC provider for authentication. While the examples use KinD (Kubernetes in Docker) for demonstration purposes, the concepts and procedures are fully applicable to any {{{ docsVersionInfo.k0rdentName }}} management cluster (for example, [Minikube](https://minikube.sigs.k8s.io/docs/start/), [MicroK8s](https://microk8s.io/), or a cloud-based cluster) that meets the minimum requirements for k0rdent.

## Prerequisites

- **{{{ docsVersionInfo.k0rdentName }}} Management Cluster:** Although KinD is used in this guide, you may use any {{{ docsVersionInfo.k0rdentName }}} management cluster that supports deploying k0rdent.
- **[Helm](https://helm.sh/):** A package manager for Kubernetes to install and manage applications.
- **[cURL](https://curl.se/):** A versatile command-line tool that enables users to send requests to network endpoints, helping to verify connectivity and inspect API responses.
- **Familiarity with basic Kubernetes operations** as well as working knowledge of TLS, DNS, and RBAC concepts.

## Step 1. Create a the {{{ docsVersionInfo.k0rdentName }}} management cluster

Follow instructions in the [documentation](../install-k0rdent.md) to install the management cluster.  

## Step 2. Install the `Pinniped` Supervisor on the management cluster

The Pinniped Supervisor is the core component that handles authentication requests and token validation.

```bash
kubectl apply -f https://get.pinniped.dev/v0.37.0/install-pinniped-supervisor.yaml
```
The Pinniped Supervisor installs the necessary resources and configures the Supervisor to manage authentication across clusters.

## Step 3. Expose the pinniped-supervisor deployment

To enable internal access to the Supervisor, expose its service:

```bash
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: pinniped-supervisor
  namespace: pinniped-supervisor
spec:
  type: ClusterIP
  selector:
    app: pinniped-supervisor
  ports:
    - protocol: TCP
      port: 443
      # TLS port of the Supervisor pods
      targetPort: 8443
EOF
```

This YAML creates a ClusterIP service that maps port 443 on the service to port 8443 on the Supervisor pods, enabling internal cluster communication over TLS.

## Step 4. Install an Ingress Controller (Contour)

You'll need an ingress controller, such as Contour, to manage external access and TLS termination.

```bash
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```

Contour handles ingress traffic and route requests to the Supervisor. {{{ docsVersionInfo.k0rdentname}}} uses it for managing external access with secure, TLS-passthrough configurations. You can accomplish the same thing with other Ingress controllers such as Nginx.

## Step 5. Create an Ingress for the Supervisor which uses TLS passthrough to allow the Supervisor to terminate TLS

```bash
cat <<EOF | kubectl apply -f -
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: supervisor-proxy
  namespace: pinniped-supervisor
spec:
  virtualhost:
    fqdn: pinniped-supervisor.pinniped-supervisor.svc.cluster.local
    tls:
      passthrough: true
  tcpproxy:
    services:
      - name: pinniped-supervisor
        port: 443
EOF
```

This configuration sets up an ingress route that directs traffic for the specified FQDN to the Supervisor service on port 443. TLS passthrough ensures that TLS termination happens at the Supervisor, preserving end-to-end encryption.

## Step 6. Check the status of the HTTP proxy

To access the Supervisor via a web browser, add a custom DNS record on your local machine.

Check that the HTTP proxy has been correctly configured and is running as expected:

```bash
kubectl get httpproxy supervisor-proxy --namespace pinniped-supervisor -o yaml
```

## Step 7. Add a custom DNS record to make it available to reach the supervisor through DNS

Do this on the machine where you will be accessing authorization via Web Browser.

### Linux `/etc/hosts`

```bash
sudo bash -c \
"echo '127.0.0.1 pinniped-supervisor.pinniped-supervisor.svc.cluster.local' >> /etc/hosts"
```

### Windows `c:\Windows\System32\Drivers\etc\hosts`

In a Powershell window with elevated privileges, type:

```shell
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "127.0.0.1 pinniped-supervisor.pinniped-supervisor.svc.cluster.local"
```

These commands add a local DNS entry so that requests to the specified FQDN are resolved to your local machine, enabling access to the Pinniped Supervisor.

## Step 8. Install cert-manager

cert-manager is used to manage TLS certificates within Kubernetes.

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.15.0/cert-manager.yaml
```
cert-manager automates the issuance and renewal of TLS certificates. This installation is essential for generating and managing certificates used by the Pinniped Supervisor.

## Step 9. Generate a self-signed certificate

Create a self-signed certificate to secure the Supervisor’s communications.

```bash
cat <<EOF | kubectl create -f -
---
# Create a self-signed issuer
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: pinniped-supervisor
spec:
  selfSigned: {}
---
# Use the self-signed issuer to create a self-signed CA
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: demo-ca
  namespace: pinniped-supervisor
spec:
  isCA: true
  commonName: demo-ca
  subject:
    organizations:
      - Project Pinniped
    organizationalUnits:
      - Demo
  secretName: demo-ca-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    group: cert-manager.io
    kind: Issuer
    name: selfsigned-issuer
---
# Create an issuer that will sign certs with our self-signed CA
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: demo-ca-issuer
  namespace: pinniped-supervisor
spec:
  ca:
    secretName: demo-ca-secret
---
# Create serving certificate using our CA, this Secret will be used by Supervisor
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: supervisor-tls-cert-request
  namespace: pinniped-supervisor
spec:
  secretName: supervisor-tls-cert
  issuerRef:
    name: demo-ca-issuer
  dnsNames:
    - pinniped-supervisor.pinniped-supervisor.svc.cluster.local
EOF
```

This multi-part YAML creates a self-signed issuer, generates a CA, and issues a serving certificate for the Pinniped Supervisor. The certificate is stored in a `Secret` and later referenced in the `FederationDomain` configuration.

## Step 10. Read the CA’s public key from the Secret and save it locally for later use

Retrieve the public key of the CA to use later when configuring the Pinniped Concierge.

```bash
kubectl get secret supervisor-tls-cert \
    --namespace pinniped-supervisor \
    -o jsonpath="{.data['ca\.crt']}" | base64 -d > /tmp/supervisor-ca.crt
```

Storing the CA's public key locally allows you to verify TLS connections and configure trust for downstream components like Pinniped Concierge.

## Step 11. Configure an Identity Provider in the Pinniped Supervisor

In this step, you configure an OIDC client application (for example, using Okta) to integrate with Pinniped. Although the configuration below references Okta, you can adjust it to use your preferred identity provider.

### Create an OIDC Client Application

1. **In the Okta Admin Console (or your identity provider):**
   - Navigate to Applications and create a new OIDC application.
   - Set the sign-in redirect URI to `https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer/callback`.
   - Note the Client ID and Client Secret.
   - Configure the token to include claims such as `email`, `groups`, and `profile`.

2. **Create a Group:**
   - In your identity provider’s admin console, create a group (e.g., `k8s-group`) and assign users who should have access to Kubernetes.

### Export the Secrets as Environment Variables

```bash
export OKTA_APP_CLIENT_ID="EXAMPLE_OKTA_APP_CLIENT_ID"
export OKTA_APP_CLIENT_SECRET="EXAMPLE_OKTA_APP_CLIENT_SECRET"
```

### Create an OIDCIdentityProvider Resource

Create the identity provider resource in Pinniped by running:

```bash
cat <<EOF | kubectl create -f -
apiVersion: idp.supervisor.pinniped.dev/v1alpha1
kind: OIDCIdentityProvider
metadata:
  namespace: pinniped-supervisor
  name: okta
spec:
  # Specify the upstream issuer URL (no trailing slash). Change this to the actual issuer provided by your identity provider.
  issuer: https://my-company.okta.com
  authorizationConfig:
    additionalScopes: [offline_access, groups, email]
    allowPasswordGrant: false
  claims:
    username: email
    groups: groups
  client:
    secretName: okta-client-credentials
---
apiVersion: v1
kind: Secret
metadata:
  namespace: pinniped-supervisor
  name: okta-client-credentials
type: secrets.pinniped.dev/oidc-client
stringData:
  clientID: "$OKTA_APP_CLIENT_ID"
  clientSecret: "$OKTA_APP_CLIENT_SECRET"
EOF
```
This resource defines how Pinniped should interact with your OIDC identity provider. It maps token claims to Kubernetes identities and securely references client credentials stored in a secret.

## Step 12. Validate the OIDCIdentityProvider Status

Ensure that the identity provider configuration is active and error-free:

```bash
kubectl describe OIDCIdentityProvider -n pinniped-supervisor okta
```

Reviewing the resource status confirms that Pinniped has successfully registered your OIDC identity provider.

## Step 13. Create and Configure a FederationDomain

The `FederationDomain` resource ties together the TLS configuration and identity providers to expose a unified issuer endpoint.

```bash
cat <<EOF | kubectl create -f -
apiVersion: config.supervisor.pinniped.dev/v1alpha1
kind: FederationDomain
metadata:
  name: demo-federation-domain
  namespace: pinniped-supervisor
spec:
  issuer: "https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer"
  tls:
    secretName: supervisor-tls-cert
  identityProviders:
    - displayName: okta
      objectRef:
        apiGroup: idp.supervisor.pinniped.dev
        kind: OIDCIdentityProvider
        name: okta
EOF
```

This `FederationDomain` configuration declares the external issuer URL, references the TLS certificate, and links the previously configured OIDC identity provider.

## Step 14. Verify the `FederationDomain` Status

Check the status of the `FederationDomain` to ensure that all components are correctly integrated:

```bash
kubectl get federationdomain demo-federation-domain --namespace pinniped-supervisor -o yaml
```

## Step 15. Verify DNS, Certificate, Ingress, and FederationDomain Integration

Test that the endpoint is accessible and properly serving OIDC configuration by using curl:

```bash
curl --cacert /tmp/supervisor-ca.crt \
    "https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer/.well-known/openid-configuration"
```

This command retrieves the OIDC discovery document, confirming that DNS resolution, TLS, ingress routing, and FederationDomain configuration are all working in unison.

## Step 16. Install Pinniped Concierge (Agent)

The Pinniped Concierge component is responsible for issuing and refreshing authentication tokens on behalf of end users.

```bash
kubectl apply -f "https://get.pinniped.dev/v0.37.0/install-pinniped-concierge-crds.yaml"
kubectl apply -f "https://get.pinniped.dev/v0.37.0/install-pinniped-concierge-resources.yaml"
```

These commands install the necessary Custom Resource Definitions (CRDs) and resources for Pinniped Concierge, enabling it to integrate with your authentication flow.

## Step 17. Prepare the CA Certificate for Concierge

Copy the base64-encoded version of the CA certificate saved earlier. This certificate is needed so that the Concierge can trust the Supervisor’s `FederationDomain`.

```bash
cat /tmp/supervisor-ca.crt | base64 -w0
```

This command outputs the CA certificate in a single base64-encoded line. Save this output for later use when configuring the Concierge.

## Step 18. Configure the Concierge with a `JWTAuthenticator`

Create a `JWTAuthenticator` resource to allow the Concierge to trust the Supervisor’s `FederationDomain`.

```bash
cat <<EOF | kubectl create -f -
apiVersion: authentication.concierge.pinniped.dev/v1alpha1
kind: JWTAuthenticator
metadata:
  name: demo-supervisor-jwt-authenticator
spec:
  issuer: "https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer"
  audience: workload1-dd9de13c370982f61e9f
  tls:
    certificateAuthorityData: "---> Paste the base64 encoded CA here <---"
EOF
```

The `JWTAuthenticator` resource configures the Concierge to trust tokens issued by the Supervisor. Replace the placeholder with the base64-encoded CA certificate you generated in the previous step.

## Step 19. Verify the `JWTAuthenticator` Status

Ensure that the JWTAuthenticator resource is ready:

```bash
kubectl get jwtauthenticator demo-supervisor-jwt-authenticator -o yaml
```
The status should indicate that the resource is in the “Ready” phase, confirming that the Concierge is configured correctly to validate tokens.

## Step 20. Create a `RoleBinding` for End-User Access

Define RBAC policies to grant authenticated users appropriate permissions. In this example, a `RoleBinding` is created to bind users from a specified identity provider group to a `ClusterRole`.


```bash
cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kcm-ns-viewer
  namespace: kcm-system
subjects:
  - kind: Group
    name: " ---> Here specify the name of your Okta group <---"
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kcm-namespace-viewer-role
EOF
```


This RoleBinding grants read-only access (as defined by the `kcm-namespace-viewer-role`) to users in the specified group, ensuring that only authorized users can view resources in the `kcm-system` namespace.

## Step 21. Install the Pinniped CLI (for AMD64)

Download and install the Pinniped CLI to interact with Pinniped resources more easily.

```bash
curl -Lso pinniped https://get.pinniped.dev/v0.37.0/pinniped-cli-linux-amd64 \
    && chmod +x pinniped \
    && sudo mv pinniped /usr/local/bin/pinniped
```


This command downloads the CLI binary, makes it executable, and moves it to a directory in your PATH for convenient access.

## Step 22. Generate Kubeconfig Files for End Users

Use the Pinniped CLI to generate a kubeconfig file that end users will use for authentication.

```bash
pinniped get kubeconfig > /tmp/developer.yaml
```

If you have multiple identity providers configured, specify the desired one:

```bash
pinniped get kubeconfig --upstream-identity-provider-name okta > /tmp/developer.yaml
```

The generated kubeconfig file contains the necessary configuration to authenticate with the cluster using Pinniped. When the command is run, it will open an authentication link in your browser. If a browser is not available, follow the command-line instructions to complete authentication.

## Step 23. Authenticate and Complete the Flow

Upon running the kubeconfig generation command, your default browser should open to an authentication page.  
- **Action:** Log in using your identity provider credentials (e.g., Okta).  
- **Outcome:** Once authenticated, an authorization code is provided and processed, generating a kubeconfig file with the proper token.


```
Current cluster info:
Name: kind-kind-pinniped
URL: https://127.0.0.1:38395

Current user info:
Username: <user@example.com>
Groups: Everyone, k8s-group, system:authenticated
```

This output confirms that the authentication flow is successful and that the RBAC permissions are applied as expected.

## Step 24. Test the Created Kubeconfig

Verify that the new kubeconfig file works by checking access to various resources.

```bash
export KUBECONFIG=/tmp/developer.yaml

kubectl auth can-i get secrets --namespace=kcm-system
kubectl auth can-i create secrets --namespace=kcm-system
```


- `kubectl auth can-i get secrets` should return "yes".
- `kubectl auth can-i create secrets` should return "no", reflecting the read-only access provided.


These tests confirm that the RBAC configuration is working correctly and that the authenticated user only has the permissions granted by the RoleBinding.

By following these detailed steps, you have set up a fully functional Pinniped-based federated authentication solution on your {{{ docsVersionInfo.k0rdentName }}} management cluster. This configuration integrates TLS, Ingress, and your chosen identity provider to provide secure, centralized access management across multiple Kubernetes clusters. The Pinniped system also periodically checks and refreshes authentication tokens, ensuring that access permissions remain up to date.
