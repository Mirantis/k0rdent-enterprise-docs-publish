# MiraCephSecret

The `MiraCephSecret` object aggregates secrets created by Rook orchestration and Ceph controller components. It is managed automatically by the ceph-controller pod and secrets-controller container.

Status fields include:
- `lastSecretCheck:` Last time secrets were checked.
- `lastSecretUpdate:` Last time secrets were updated.
- `state:` Current state of the secrets check.
- `secretInfo:` Details about secrets, including lists for:
    - `clientSecrets:` Secrets for Ceph clients.
    - `rgwUserSecrets:` Secrets for Ceph RGW users.

Example:
```yaml
status:
  lastSecretCheck: "2024-07-23T13:40:37Z"
  lastSecretUpdate: "2024-07-16T15:58:15Z"
  secretInfo:
    clientSecrets:
      - name: client.admin
        secretName: rook-ceph-admin-keyring
        secretNamespace: rook-ceph
      - name: client.cinder
        secretName: rook-ceph-client-cinder
        secretNamespace: rook-ceph
      - name: client.glance
        secretName: rook-ceph-client-glance
        secretNamespace: rook-ceph
      - name: client.nova
        secretName: rook-ceph-client-nova
        secretNamespace: rook-ceph
    rgwUserSecrets:
      - name: rgw-ceilometer
        secretName: rook-ceph-object-user-openstack-store-rgw-ceilometer
        secretNamespace: rook-ceph
  state: Ready
```
