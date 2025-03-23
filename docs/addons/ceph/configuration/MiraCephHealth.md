# MiraCephHealth

The `MiraCephHealth` object aggregates all statuses from the Ceph cluster. It is updated automatically by the ceph-controller’s status-controller.

Status fields include:
1. `lastCheck:` Time of the last status check.
2. `lastUpdate:` Time of the last update.
3. `state:` Current state of the status check (e.g., Ready means no issues).
4. `messages:` Descriptions of any detected issues.
5. `miraCephGeneration:` Generation of the MiraCeph object used for status checks.
6. `fullClusterStatus:` Overall cluster status including details on block storage, daemon statuses, usage, and conditions.

*(A detailed example is provided in the full documentation.)*
