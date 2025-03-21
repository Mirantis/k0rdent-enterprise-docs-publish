# Pinniped

This tutorial is intended to be a Step-by-Step example of installing and configuring the `Pinniped` components to provide a multi-cluster federated authentication solution

## Prerequisites

- KinD for setting up a k8s cluster (Kubeadm/KubeSpray clusters are also applicable).
- Helm for installing charts.
- cURL for endpoint validation.

## Step 1. Create a k8s cluster

```bash
cat <<EOF > /tmp/kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - protocol: TCP
        containerPort: 443
        hostPort: 443
        listenAddress: 0.0.0.0
EOF

kind create cluster --config /tmp/kind-config.yaml
```

## Step 2. Deploy k0rdent to the cluster using Helm

```bash
helm install kcm oci://ghcr.io/k0rdent/kcm/charts/kcm --version 0.1.0 -n kcm-system --create-namespace
```

## Step 3. Verify that k0rdent is running

```bash
kubectl get pods -n kcm-system
```

## Step 4. Install the `Pinniped` Supervisor on the supervisor cluster

```bash
kubectl apply -f https://get.pinniped.dev/v0.37.0/install-pinniped-supervisor.yaml
```

## Step 5. Expose the pinniped-supervisor deployment

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

## Step 6. Install an Ingress Controller (Contour)

```bash
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```

## Step 7. Create an Ingress for the Supervisor which uses TLS passthrough to allow the Supervisor to terminate TLS

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

## Step 8. Check the status of the HTTP proxy

```bash
kubectl get httpproxy supervisor-proxy --namespace pinniped-supervisor -o yaml
```

## Step 9. Add a custom DNS record to make it available to reach the supervisor through DNS

Do this on the machine where you will be accessing authorization via Web Browser.

### Linux `/etc/hosts`

```bash
sudo bash -c \
"echo '127.0.0.1 pinniped-supervisor.pinniped-supervisor.svc.cluster.local' >> /etc/hosts"
```

### Windows `c:\Windows\System32\Drivers\etc\hosts`

--- ToDo

## Step 10. Install cert-manager

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.15.0/cert-manager.yaml
```

## Step 11. Generate a self-signed certificate

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

## Step 12. Read the CA’s public key from the Secret and save it locally for later use

```bash
kubectl get secret supervisor-tls-cert \
    --namespace pinniped-supervisor \
    -o jsonpath="{.data['ca\.crt']}" | base64 -d > /tmp/supervisor-ca.crt
```

## Step 13. Configure an Identity Provider in the `Pinniped` Supervisor

### Create an OIDC client app

- In the Okta Admin Console, navigate to Applications > Applications.
- Create a new app:
- Click Create App Integration.
- For the Sign-on method, select OIDC.
- For Application type, app Web Application, then click next. Only if you would like to offer the password grant flow to your end users should you choose Native Application instead.
- Enter a name for your app, such as "My Kubernetes Clusters". If you chose to create a Web Application then in the General Settings section, choose Grant Types Authorization Code and Refresh Token. If you chose Native Application then in the General Settings section, choose Grant Types Authorization Code, Refresh Token, and Resource Owner Password.
- Enter the sign-in redirect URI. This will the `spec.issuer` you will be configuring in your FederationDomain appended with "/callback", in our dem this value will be `https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer/callback`.
- Optionally select Limit access to selected groups to restrict which Okta users can log in to Kubernetes using this integration.
- Save the app and make note of the Client ID and Client secret. If you chose to create a Native Application then there is an extra step required to get a client secret: after saving the app, in the Client Credentials section click Edit, choose Use Client Authentication, and click Save.
- Navigate to the Sign On tab > OpenID Connect ID Token and click Edit. Fill in the Groups claim filter. For example, for all groups to be present under the claim name groups, fill in "groups" in the first box, then select "Matches regex" and ".*".

### Create a group

- Go to your Okta admin console
- Go to the sidebar menu and select Directory > Groups > Add Group.
- Then enter a name in the Name field, in the demo we use `k8s-group`.
- Click Save. Then from the Group screen, go to the People tab and click on Assign people.

## Step 14. Export the secrets as variables

```bash
export OKTA_APP_CLIENT_ID="paste client ID here"
export OKTA_APP_CLIENT_SECRET="paste client secret here"
```

## Step 15. Create an OIDCIdentityProvider in the same namespace as the Supervisor

```bash
cat <<EOF | kubectl create -f -
apiVersion: idp.supervisor.pinniped.dev/v1alpha1
kind: OIDCIdentityProvider
metadata:
  namespace: pinniped-supervisor
  name: okta
spec:
  # Specify the upstream issuer URL (no trailing slash). Change this to the actual issuer provided by your Okta account
  issuer: https://my-company.okta.com
  # Specify how to form authorization requests to Okta
  authorizationConfig:
    # Request any scopes other than "openid" for claims besides the default claims in your token. The "openid" scope is always included
    # To learn more about how to customize the claims returned, see here
    # https://developer.okta.com/docs/guides/customize-tokens-returned-from-okta/overview/
    additionalScopes: [offline_access, groups, email]
    # If you would also like to allow your end users to authenticate using a password grant, then change this to true. Password grants only work with applications created in Okta as "Native Applications"
    allowPasswordGrant: false
  # Specify how Okta claims are mapped to Kubernetes identities
  claims:
    # Specify the name of the claim in your Okta token that will be mapped to the "username" claim in downstream tokens minted by the Supervisor
    username: email
    # Specify the name of the claim in Okta that represents the groups that the user belongs to. This matches what you specified above with the Groups claim filter
    groups: groups
  # Specify the name of the Kubernetes Secret that contains your Okta application's client credentials (created below)
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

## Step 16. Validate the OIDCIdentityProvider status

```bash
kubectl describe OIDCIdentityProvider -n pinniped-supervisor okta
```

## Step 17. Create and configure a FederationDomain in the `Pinniped` Supervisor namespace

```bash
cat <<EOF | kubectl create -f -
apiVersion: config.supervisor.pinniped.dev/v1alpha1
kind: FederationDomain
metadata:
  name: demo-federation-domain
  namespace: pinniped-supervisor
spec:
  # You can choose an arbitrary path for the issuer URL
  issuer: "https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer"
  tls:
    # The name of the secretName from the cert-manager Certificate resource above
    secretName: supervisor-tls-cert
  identityProviders:
    - displayName: okta
      objectRef:
        apiGroup: idp.supervisor.pinniped.dev
        kind: OIDCIdentityProvider
        name: okta
EOF
```

## Step 18. Check that the FederationDomain status

```bash
kubectl get federationdomain demo-federation-domain --namespace pinniped-supervisor -o yaml
```

## Step 19. Check that the DNS, certificate, ingress, and FederationDomain are all working together by trying to fetch one of its endpoints

```bash
curl --cacert /tmp/supervisor-ca.crt \
    "https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer/.well-known/openid-configuration"
```

## Step 20. Install Concierge (agent)

```bash
kubectl apply -f \
    "https://get.pinniped.dev/v0.37.0/install-pinniped-concierge-crds.yaml"

kubectl apply -f \
    "https://get.pinniped.dev/v0.37.0/install-pinniped-concierge-resources.yaml"
```

## Step 21. Copy the base64 encoded version of our CA cert saved earlier

```bash
cat /tmp/supervisor-ca.crt | base64 -w0
```

## Step 22. Configure the Concierge to trust the Supervisor’s FederationDomain for authentication by creating a JWTAuthenticator

```bash
cat <<EOF | kubectl create -f -
apiVersion: authentication.concierge.pinniped.dev/v1alpha1
kind: JWTAuthenticator
metadata:
  name: demo-supervisor-jwt-authenticator
spec:
  # This should be the issuer URL that was declared in the FederationDomain
  issuer: "https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer"
  # The audience value below is an arbitrary value that must uniquely identify this cluster. No other workload cluster should use the same value
  # It can have a human-readable component, but part of it should be random enough to ensure its uniqueness. Since this tutorial only uses a single cluster, you can copy/paste this example value
  audience: workload1-dd9de13c370982f61e9f
  tls:
    certificateAuthorityData: "---> Paste the base64 encoded CA here <---"
EOF
```

## Step 23. Check the status of the created JWTAuthenticator, it should be in phase “Ready”

```bash
kubectl get jwtauthenticator demo-supervisor-jwt-authenticator -o yaml
```

## Step 24. Create a RoleBinding to the KCM ClusterRole for users, groups of your OKTA tenant

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

## Step 25. Install the `Pinniped` CLI (for AMD64)

```bash
curl -Lso pinniped https://get.pinniped.dev/v0.37.0/pinniped-cli-linux-amd64 \
    && chmod +x pinniped \
    && sudo mv pinniped /usr/local/bin/pinniped
```

## Step 26. Create kubeconfig files for the end-user

```bash
pinniped get kubeconfig > /tmp/developer.yaml
```

**\#** P.S. If you have configured more than one `identityProvider` then you should pass the name of this IDP as well.

```bash
Error: multiple Supervisor upstream identity providers were found, so the --upstream-identity-provider-name/--upstream-identity-provider-type flags must be specified. Found these upstreams: [{"name":"GitHub.com","type":"github","flows":["browser_authcode"]},{"name":"okta","type":"oidc","flows":["browser_authcode"]}]
```

**\#** In my case I have set 2 IDP providers and thus I run the following command:

```bash
pinniped get kubeconfig --upstream-identity-provider-name okta > /tmp/developer.yaml
```

**\#** After running this command, the authentication link should automatically open in your default browser (if one is available). If you are in a CLI environment or do not have a browser installed, follow these steps instead:

```bash
pinniped whoami --kubeconfig /tmp/developer.yaml

Tue, 11 Feb 2025 08:27:46 UTC oidcclient/login.go:888 could not open browser {"error": "exec: \"xdg-open,x-www-browser,www-browser\": executable file not found in $PATH"}

Log in by visiting this link:

    https://pinniped-supervisor.pinniped-supervisor.svc.cluster.local/demo-issuer/oauth2/authorize?access_type=offline&client_id=pinniped-cli&code_challenge=6BerKgOGAuKLYAGc65sk-sDMtQmcjz4McuTSoTCLnrc&code_challenge_method=S256&nonce=a987151f08933c002428f2e93eeffaad&pinniped_idp_name=okta&pinniped_idp_type=oidc&redirect_uri=http%3A%2F%2F127.0.0.1%3A39371%2Fcallback&response_mode=form_post&response_type=code&scope=groups+offline_access+openid+pinniped%3Arequest-audience+username&state=4ff87f26335b8848c57c5973b03cf22c

    Optionally, paste your authorization code:
```

**\#** Open above link in Web Browser and authorize via Okta.

**\#** P.S. You must be able to access `pinniped-supervisor.pinniped-supervisor.svc.cluster.local` on port 443. If necessary, add this domain name to your hosts file.

## Step 27. Perform authentication via your Okta credentials and copy the authorization code provided after

Paste the authorization code to the prompt field from previous step.

```bash
    Optionally, paste your authorization code: pin_ac_***

Current cluster info:

Name: kind-kind-pinniped
URL: https://127.0.0.1:38395

Current user info:

Username: <omahmudzada@gmail.com>
Groups: Everyone, k8s-group, system:authenticated
```

**\#** In the groups directive you can see the groups the user is a member of.

## Step 28. Test the created kubeconfig

```bash
export KUBECONFIG=/tmp/developer.yaml

~# kubectl auth can-i get secrets --namespace=kcm-system

yes

~# kubectl auth can-i create secrets --namespace=kcm-system

no
```

**\#** As you can see the RBAC roles are working as expected.

**\#** From this point forward, this kubeconfig file may be provided to the user.

**\#** P.S. `Pinniped` performs periodic checks on issued tokens every 5 minutes. If a user who belongs to a group with assigned RBAC permissions is removed from that group, `Pinniped` will revoke their access within 5 minutes.
