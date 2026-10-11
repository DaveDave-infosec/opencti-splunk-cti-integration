# Splunk Example Searches

## 1. Verify the OpenCTI lookup

```spl
| inputlookup opencti-domains.csv
| head 10
```

Use this first to confirm Splunk can read the synchronized CSV lookup.

## 2. Test an IOC lookup match

```spl
| makeresults
| eval test_domain="gitprogram.com"
| lookup opencti-domains.csv domain AS test_domain OUTPUT domain AS matched_domain
```

A populated `matched_domain` field confirms the lookup is working.

## 3. Enrich DNS events

Replace the field names below with the fields used by your DNS data source.

```spl
index=<dns_index>
| rename query AS observed_domain
| lookup opencti-domains.csv domain AS observed_domain OUTPUT domain AS threat_match
| where isnotnull(threat_match)
| table _time host user observed_domain threat_match
```

## 4. Enrich network or proxy telemetry

```spl
index=<network_index>
| rename dest_domain AS observed_domain
| lookup opencti-domains.csv domain AS observed_domain OUTPUT domain AS threat_match
| where isnotnull(threat_match)
| table _time src_ip dest_ip user observed_domain threat_match
```

## Analyst Reminder

A lookup hit is not automatically proof of compromise.

Use the match as a pivot:

```text
IOC match
  -> host
  -> user/process
  -> timeline
  -> before/after activity
  -> scope
  -> conclusion
```
