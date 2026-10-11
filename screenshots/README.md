# Screenshot Checklist

Add sanitized screenshots here as evidence that the project works.

Recommended screenshots:

1. **OpenCTI AlienVault connector**
   - show connector status
   - hide API keys and tokens

2. **OpenCTI CSV feed**
   - show the Domain-Name feed configuration
   - avoid exposing sensitive tokens

3. **Splunk inputlookup**
   - run:
     ```spl
     | inputlookup opencti-domains.csv
     | head 10
     ```

4. **Splunk IOC match**
   - run:
     ```spl
     | makeresults
     | eval test_domain="gitprogram.com"
     | lookup opencti-domains.csv domain AS test_domain OUTPUT domain AS matched_domain
     ```

5. **Automated sync proof**
   - show cron entry or syslog execution
   - show the lookup file timestamp after an automatic refresh

## Before Uploading

Review every screenshot for:

- API keys
- tokens
- passwords
- encryption keys
- cookies
- browser session data
- email addresses you do not want public
- unrelated private information
