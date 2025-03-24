# CephPerfTestRequest

The `CephPerfTestRequest` object is designed to run periodic performance tests using [FIO](https://fio.readthedocs.io/en/latest/fio_doc.html) (Flexible I/O Tester) in a Kubernetes job or cronjob. Test results can be stored on a persistent volume (secured with a PVC).

## Spec

The `spec` section includes:

- `parameters:` List of arguments for the FIO test.
- `command:` Entrypoint command to run the test (optional; defaults to the image’s entrypoint).
- `image:` The container image used for testing (default recommended is `vineethac/fio_image`).
- `periodic:` Configuration for running the test periodically:
    - `schedule`: Cron-formatted schedule.
    - `suspended`: Flag to suspend the job.
    - `runsToKeep`: Number of previous runs to retain.
- `saveResultOnPvc:` Configuration for saving test results:
    - `pvcName`: Name of the PVC.
    - `pvcStorageClass`: StorageClass to use.
    - `pvcSize`: Size of the PVC.
    - `preserveOnDelete`: Whether to retain the PVC on deletion.

Example:
```yaml
spec:
  periodic:
    schedule: "0 */10 * * *"
    runsToKeep: 10
  parameters:
  - --ioengine=rbd
  - --pool=mirablock-k8s-block-hdd
  - --rbdname=tests
  - --name=hourly_perftest
  - --rw=randrw:16k
  - --rwmixread=40
  - --bs=4k
  - --size=500M
  - --iodepth=32
  - --numjobs=8
  - --group_reporting
  - --direct=1
  - --fsync=32
  - --buffered=0
  - --exitall
  saveResultOnPvc:
    pvcName: "perf-test-pvs"
    pvcSize: "1Gi"
```

## Status

The `status` section provides:

- `phase:` Current phase of the test (e.g., Pending, Running, Finished).
- `lastStartTime:` Time when the test started.
- `lastDurationTime:` Duration of the test run.
- `lastJobStatus:` Status of the last test job.
- `messages:` Any warnings or issues.
- `results:` Details on where to find the results:
    - `perftestReference`
    - `referenceNamespace`
    - `storedOnPvc`
- `statusHistory:` History of test runs including start time, job status, and duration.

Example:
```yaml
status:
  lastJobStatus: Running
  lastStartTime: "2024-07-30T10:56:00Z"
  phase: Running
  results:
    perftestReference: cronjob/testperf-cephperftest
    referenceNamespace: rook-ceph
    storedOnPvc:
      pvcName: perf-test-pvs
      pvcNamespace: rook-ceph
  statusHistory:
  - durationTime: 4m34s
    jobStatus: Completed
    startTime: "2024-07-30T00:51:25Z"
```
