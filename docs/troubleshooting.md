# Troubleshooting Notes

This file documents the major problems encountered while building the lab and the lessons learned from each one.

## 1. OpenCTI disk exhaustion

### Symptom
The OpenCTI VM ran out of usable root filesystem space even though the VMware virtual disk had been expanded.

### Root cause
The virtual disk was larger, but the Linux partition, LVM physical volume, logical volume, and filesystem had not all been expanded to consume the new capacity.

### Fix
The disk was expanded through the Linux storage layers using tools such as `growpart`, `pvresize`, `lvextend`, and `resize2fs`.

### Lesson
Increasing the virtual disk size in VMware does not automatically increase the mounted Linux filesystem.

---

## 2. OpenCTI memory pressure and OOM conditions

### Symptom
OpenCTI services became unstable, swap was exhausted, and Java-based components were killed.

### Root cause
The full OpenCTI stack was running on a VM with insufficient memory.

### Fix
The VM memory was increased to approximately 8 GB.

### Lesson
OpenCTI is a multi-service platform. Elasticsearch, RabbitMQ, Redis, workers, connectors, and the application server all compete for memory.

---

## 3. Redis RDB corruption

### Symptom
Redis entered a restart loop and OpenCTI could not start correctly.

### Evidence
Redis logs showed:

```text
Invalid LZF compressed string
RDB ERROR DETECTED
```

### Root cause
The Redis persistence file was corrupted.

### Fix
The corrupt `dump.rdb` was moved aside and Redis was restarted.

### Lesson
Check dependency logs before assuming the main application is the failing component. Redis was holding transient state, while core OpenCTI data remained in its other backing services.

---

## 4. AlienVault timestamp parsing failure

### Symptom
The connector returned:

```text
unconverted data remains: Z
```

### Root cause
The configured value ended in `Z`:

```text
2020-05-01T00:00:00Z
```

The connector implementation expected a timestamp format without the trailing `Z`.

### Fix
The value was changed to:

```text
2020-05-01T00:00:00
```

### Lesson
A value can be valid ISO 8601 while still being incompatible with a connector's parser.

---

## 5. Excessive historical OTX import

### Symptom
OpenCTI showed severe ingestion backpressure and millions of queued bundles.

RabbitMQ showed roughly 3.9 million queued messages for the AlienVault connector.

### Root cause
The connector had been configured to ingest data starting from 2020, which was too large a history window for the lab environment.

### Fix
The AlienVault connector was stopped, its specific RabbitMQ queue was identified and purged, and the start date was reduced to a recent lab window.

### Lesson
Threat-intelligence ingestion should be scoped according to infrastructure capacity. More historical data is not automatically better.

---

## 6. Legacy Docker Compose ContainerConfig error

### Symptom
Recreating containers sometimes failed with:

```text
KeyError: 'ContainerConfig'
```

### Root cause
The environment was using legacy Docker Compose 1.29.2.

### Fix
The stale affected container was removed and then recreated with Docker Compose.

### Lesson
Container troubleshooting can depend heavily on Compose version and runtime behavior.

---

## 7. VMware networking mismatch

### Symptom
The Splunk VM could not reach the OpenCTI CSV feed.

### Environment
OpenCTI was on a VMware NAT network:

```text
192.168.119.129/24
```

Splunk initially had only a bridged interface:

```text
192.168.1.192/24
```

### Fix
A second VMware network adapter using NAT was added to the Splunk VM.

Splunk then had:

```text
ens33 -> 192.168.1.192/24
ens37 -> 192.168.119.130/24
```

This placed a Splunk interface on the same virtual subnet as OpenCTI.

### Lesson
Two VMs can both have network access while still being unable to communicate directly if they are attached to different virtual networks without routing between them.

---

## 8. Splunk Free authentication-token limitation

### Symptom
The OpenCTI-to-Splunk connector workflow used in the original lab could not be reproduced.

### Root cause
The lab used Splunk Free, which did not expose the required user authentication-token workflow.

### Fix
The integration architecture was adapted to:

```text
OpenCTI CSV feed -> Bash sync -> Splunk CSV lookup
```

### Lesson
The objective matters more than copying one implementation exactly. A licensing constraint can require redesign while preserving the security use case.

---

## 9. cron automation verification

### Goal
Prove the CSV feed was updating automatically rather than only during manual script runs.

### Validation
The following checks were used:

```bash
grep "sync_opencti_feed" /var/log/syslog | tail -10
```

This confirmed cron launched the script.

Then:

```bash
ls -l /opt/splunk/etc/apps/search/lookups/opencti-domains.csv
```

The lookup timestamp changed automatically at the scheduled 30-minute execution.

### Lesson
Validate every layer separately:

```text
cron trigger -> script -> download -> lookup replacement
```
