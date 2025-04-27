# Verifying {{{ docsVersionInfo.k0rdentName }}} Artifacts and Security

Mirantis provides security artifacts for {{{ docsVersionInfo.k0rdentName }}} releases to ensure software supply chain transparency and enable users to verify the integrity and composition of the software. These artifacts include cryptographically signed binaries and container images, Software Bills of Materials (SBOMs), and CVE scan reports.

Verifying these artifacts is a critical step to ensure you are running genuine, untampered software and to assess its security posture before deployment.

## Artifact Signature Verification with Cosign

All {{{ docsVersionInfo.k0rdentName }}} release artifacts (container images, binary files, reports) are cryptographically signed. Verification requires the [`cosign` command-line tool](https://github.com/sigstore/cosign/releases).

### Verifying OCI Container Images

Use the `cosign verify` command, specifying the public key (`https://get.mirantis.com/k0rdent-enterprise/cosign.pub`) and the full image path, as in:

```bash
cosign verify --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub registry.mirantis.com/k0rdent-enterprise/<image-name>:<tag>
```

For example, you can verify the `kcm-controller:0.1.0` component with:

```bash
cosign verify --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub registry.mirantis.com/k0rdent-enterprise/kcm-controller:0.1.0
```

### Verifying Binary Artifacts (Reports, Binaries)

Binary artifacts (such as executables, or even the text-based `cve_report.txt`) have a corresponding `.sig` file containing the signature, located alongside the artifact. To verify these artifacts:

1.  Download both the artifact file and its `.sig` file.
2.  Use the `cosign verify-blob` command:

     ```shell
     cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature <artifact-name>.sig <artifact-name>
     ```

     For example, verify the version 0.1.0 `cve_report.txt`file:

     ```shell
     wget https://get.mirantis.com/k0rdent-enterprise/0.1.0/cve_report.txt
     wget https://get.mirantis.com/k0rdent-enterprise/0.1.0/cve_report.txt.sig
     cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature cve_report.txt.sig cve_report.txt
     ```
     ```console
     Verified OK
     ```

Successful verification confirms the artifact's authenticity and integrity.

## Software Bill of Materials (SBOMs)

Mirantis provides SBOMs in the SPDX format for {{{ docsVersionInfo.k0rdentName }}} components. SBOMs offer a detailed inventory of software ingredients, making it possible to manage vulnerabilities, perform license compliance checks, and understand software dependencies.

### Locating SBOMs

For each release version, an `sbom_list` file contains direct URLs to the SPDX SBOM files for associated artifacts. For example for version 0.1.0, this list file is located at:

```
http://get.mirantis.com/k0rdent-enterprise/0.1.0/sbom_list
```

The individual SBOM files (in SPDX JSON format) listed within `sbom_list` can be downloaded from the base artifact path: `https://get.mirantis.com/k0rdent-enterprise/`

These SPDX files can be processed using standard SBOM analysis tools to assess components and dependencies. Remember to adapt the version number in the path (`/0.1.0/`) for different releases.

## CVE Reports

Alongside SBOMs, Mirantis provides reports from CVE (Common Vulnerabilities and Exposures) scans performed on the release artifacts. These reports offer a snapshot of known vulnerabilities detected at the time of the scan.

The report is typically provided as a text file. For example the version 0.1.0 file can be found at:

```
https://get.mirantis.com/k0rdent-enterprise/0.1.0/cve_report.txt
```

> IMPORTANT: 
> Even though it isn't software, remember to download the corresponding `.sig` file and verify the integrity of the downloaded CVE report using the `cosign verify-blob` command before relying on its contents. Note that certain characters might not render correctly when viewing the `.txt` file directly in some browsers; downloading is recommended.
