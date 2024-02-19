#!/usr/bin/env bash
# =============================================================================
#  2024-02-19 - CraHan <crahan@n00.be>
# =============================================================================

# Profile
profile=${aws_profile:-"default"}

# Retrieve S3 bucket names
buckets=$(aws --profile $profile s3api list-buckets --query 'Buckets[].Name' | jq -r '.[]')

# Data table header
bucket_data="Bucket Name,HTTPS,Versioning,Logging,Encryption\n"

# Iterate over each bucket name
for bucket in $buckets; do
  # Retrieve Secure Transport (HTTPS) configuration
  secure_transport=$(aws --profile $profile s3api get-bucket-policy --bucket $bucket --query 'Policy' --output text 2>/dev/null | jq -r '.Statement[] | select(.Condition.Bool."aws:SecureTransport" == "false") | .Effect')
  [ "$secure_transport" == "Deny" ] && secure_transport="Yes" || secure_transport="No"

  # Retrieve versioning configuration
  versioning=$(aws --profile $profile s3api get-bucket-versioning --bucket $bucket --query 'Status' --output text 2>/dev/null)
  [ "$versioning" == "Enabled" ] && versioning="Yes" || versioning="No"

  # Retrieve logging configuration
  logging=$(aws --profile $profile s3api get-bucket-logging --bucket $bucket --query 'LoggingEnabled' --output text 2>/dev/null)
  [ "$logging" != "None" ] && logging="Yes" || logging="No"

  # Retrieve default encryption configuration
  encryption=$(aws --profile $profile s3api get-bucket-encryption --bucket $bucket --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null)
  [ "$encryption" != "None" ] && encryption="Yes" || encryption="No"

  # Append bucket details to data table
  bucket_data+="$bucket,$secure_transport,$versioning,$logging,$encryption\n"
done

# Print data table
echo -e $bucket_data
