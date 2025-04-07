#!/usr/bin/env bash
# =============================================================================
#  2025-05-07 - CraHan <crahan@n00.be>
# =============================================================================

# Get all distribution IDs
aws cloudfront list-distributions --output json | jq -r '.DistributionList.Items[].Id' | while read -r id; do
  # Get full distribution config
  dist=$(aws cloudfront get-distribution --id "$id" --output json)

  # Extract values
  defaultRootObject=$(echo "$dist" | jq -r '.Distribution.DistributionConfig.DefaultRootObject // "None"')
  webACLId=$(echo "$dist" | jq -r '.Distribution.DistributionConfig.WebACLId // "None"')
  loggingEnabled=$(echo "$dist" | jq -r '.Distribution.DistributionConfig.Logging.Enabled // "None"')
  viewerProtocolPolicy=$(echo "$dist" | jq -r '.Distribution.DistributionConfig.DefaultCacheBehavior.ViewerProtocolPolicy // "None"')
  viewerCertMinProtoVer=$(echo "$dist" | jq -r '.Distribution.DistributionConfig.ViewerCertificate.MinimumProtocolVersion // "None"')
  originProtocolPolicy=$(echo "$dist" | jq -r '.Distribution.DistributionConfig.Origins.Items[0].CustomOriginConfig.OriginProtocolPolicy // "None"')

  # Join SSL protocols into pipe-separated string or default to None
  sslProtocols=$(echo "$dist" | jq -r '.Distribution.DistributionConfig.Origins.Items[0].CustomOriginConfig.OriginSslProtocols.Items[]? // empty' | paste -sd'|' -)
  [[ -z "$sslProtocols" ]] && sslProtocols="None"

  # Output
  echo "===== CloudFront Distribution: $id"
  echo "- DefaultRootObject: $defaultRootObject"
  echo "- WebACLAttached: $webACLId"
  echo "- LoggingEnabled: $loggingEnabled"
  echo "- ViewerProtocolPolicy: $viewerProtocolPolicy"
  echo "- ViewerCertMinProtoVer: $viewerCertMinProtoVer"
  echo "- OriginProtocolPolicy: $originProtocolPolicy"
  echo "- OriginSslProtocols: $sslProtocols"
  echo ""
done
