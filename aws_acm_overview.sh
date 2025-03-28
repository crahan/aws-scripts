#!/usr/bin/env bash
# =============================================================================
#  2025-03-28 - CraHan <crahan@n00.be>
# =============================================================================

for region in $regions; do
  echo "===== Region: $region"

  certs=$(aws acm list-certificates --region "$region" --output json)

  echo "$certs" | jq -c '.CertificateSummaryList[]' | while read cert_summary; do
    arn=$(echo "$cert_summary" | jq -r '.CertificateArn')
    inuse=$(echo "$cert_summary" | jq -r '.InUse')
    cert_json=$(aws acm describe-certificate --region "$region" --certificate-arn "$arn" --output json)
    domain=$(echo "$cert_json" | jq -r '.Certificate.DomainName')
    type=$(echo "$cert_json" | jq -r '.Certificate.Type')
    imported=false

    if [ "$type" == "IMPORTED" ]; then
      imported=true
    fi

    ctlogging=$(echo "$cert_json" | jq -r '.Certificate.Options.CertificateTransparencyLoggingPreference // "N/A"')
    notafter=$(echo "$cert_json" | jq -r '.Certificate.NotAfter')

    echo "Domain     : $domain"
    echo "ARN        : $arn"
    echo "Imported   : $imported"
    echo "CTLogging  : $ctlogging"
    echo "NotAfter   : $notafter"
    echo "InUse      : $inuse"
    echo ""
  done
done
