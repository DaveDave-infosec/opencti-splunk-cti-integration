# Architecture Notes

## Data Flow

```text
AlienVault OTX
    |
    | threat intelligence
    v
OpenCTI
    |
    | filtered Domain-Name CSV feed
    v
Bash synchronization script
    |
    | scheduled every 30 minutes by cron
    v
Splunk Free CSV lookup
    |
    | lookup enrichment
    v
SOC investigation
```

## Design Decision

The original training workflow used:

```text
OpenCTI -> Splunk connector -> Splunk authentication token -> KV Store
```

The lab used Splunk Free, so the authentication-token integration was not available.

The adapted design uses a standard CSV lookup instead:

```text
OpenCTI -> CSV feed -> Bash/cron -> Splunk lookup
```

This preserves the security objective while remaining compatible with the lab license.

## Network Layout

The OpenCTI VM and Splunk VM needed a shared VMware NAT network for direct communication.

```text
VMware NAT: 192.168.119.0/24

OpenCTI:
192.168.119.129

Splunk NAT interface:
192.168.119.130
```

Splunk also retained its original bridged interface for normal lab access.

## Trust Boundary

The OpenCTI CSV feed was made public only inside an isolated lab.

For production, use authentication and network controls appropriate to the sensitivity of the threat-intelligence data.
