# Verifying {{{ docsVersionInfo.k0rdentName }}} Artifacts and Security

Mirantis provides security artifacts for {{{ docsVersionInfo.k0rdentName }}}
releases to ensure software supply chain transparency and enable users to verify
the integrity and composition of the software. These artifacts include
cryptographically signed binaries and container images, Software Bills of
Materials (SBOMs), and CVE scan reports.

Verifying these artifacts is a critical step to ensure you are running genuine,
untampered software and to assess its security posture before deployment.

## Artifact Signature Verification with Cosign

All {{{ docsVersionInfo.k0rdentName }}} release artifacts (container images,
binary files, reports) are cryptographically signed. Verification requires the
[`cosign` command-line tool](https://github.com/sigstore/cosign/releases).

### Verifying OCI Container Images

Use the `cosign verify` command, specifying the public key
(`https://get.mirantis.com/k0rdent-enterprise/cosign.pub`) and the full image
path, as in:

```bash
cosign verify --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub registry.mirantis.com/k0rdent-enterprise/<image-name>:<tag>
```

For example, you can verify the `kcm-controller:{{{ extra.docsVersionInfo.k0rdentDotVersion }}}` component with:

```bash
cosign verify --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub registry.mirantis.com/k0rdent-enterprise/kcm-controller:{{{ extra.docsVersionInfo.k0rdentDotVersion }}}
```

### Verifying Binary Artifacts (Reports, Binaries)

Binary artifacts (such as executables) have a corresponding `.sig` file
containing the signature, located alongside the artifact. To verify these
artifacts:

1.  Download both the artifact file and its `.sig` file.
2.  Use the `cosign verify-blob` command:

     ```shell
     cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature <artifact-name>.sig <artifact-name>
     ```

     For example, verify the version {{{ extra.docsVersionInfo.k0rdentDotVersion }}}
	 `release.yaml`file:

     ```shell
     wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/release.yaml
     wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/release.yaml.sig
     cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature release.yaml.sig release.yaml
     ```
     ```console
     Verified OK
     ```

Successful verification confirms the artifact's authenticity and integrity.

## Software Bill of Materials (SBOMs)

Mirantis provides SBOMs in the SPDX format for {{{ docsVersionInfo.k0rdentName }}}
components. SBOMs offer a detailed inventory of software ingredients, making
it possible to manage vulnerabilities, perform license compliance checks, and
understand software dependencies.

### Getting SBOMs

Each OCI artifact contains an SBOM attached to it in the SPDX format. To get the SBOM
you can use `cosign`.

> NOTE:
> Since `cosign` returns predicates in json format `jq` must be used to query
> specific fields, like contents of the SPDX.

For example to get the SPDX for
`kcm-controller:{{{extra.docsVersionInfo.k0rdentDotVersion }}}` you can use
the following command:

```bash
cosign verify-attestation --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --type spdx registry.mirantis.com/k0rdent-enterprise/kcm-controller:{{{ extra.docsVersionInfo.k0rdentDotVersion }}} | jq '.payload | @base64d | fromjson | .predicate' -r
```

This will get you a full SPDX file for `kcm-controller` and also will verify
authenticity (attestation) of the attached SPDX.


## CVE Reports

CVE scans are also attached to the OCI artifacts as a
form of attestation. CVE reports are generated using the `trivy` scanner and are
provided in the
[Cosign Vulnerability Scan Record format](https://github.com/sigstore/cosign/blob/95b74db89941e8ec85e768f639efd4d948db06cd/specs/COSIGN_VULN_ATTESTATION_SPEC.md).

You can use `cosign` to get the CVE report for a specific artifact.

For example, to get CVE vulnerability scan for
`kcm-controller:{{{extra.docsVersionInfo.k0rdentDotVersion }}}` you can use:

```bash
cosign verify-attestation --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --type vuln registry.mirantis.com/k0rdent-enterprise/kcm-controller:{{{ extra.docsVersionInfo.k0rdentDotVersion }}} | jq '.payload | @base64d | fromjson | .' -r
```

This command returns JSON with the cosign vulnerability scan record attestation. It also
verifies the authenticity of the data.
