#!/bin/bash

# OpenCTI CSV feed -> Splunk lookup synchronizer
# Replace the placeholder feed URL before use.

FEED_URL="http://<OPENCTI_HOST>:8080/feeds/<FEED_ID>"
TMP_FILE="/tmp/opencti-domains.csv"
SPLUNK_LOOKUP="/opt/splunk/etc/apps/search/lookups/opencti-domains.csv"

curl -fsS "$FEED_URL" -o "$TMP_FILE"

if [ $? -eq 0 ] && [ -s "$TMP_FILE" ]; then
    cp "$TMP_FILE" "$SPLUNK_LOOKUP"
fi
