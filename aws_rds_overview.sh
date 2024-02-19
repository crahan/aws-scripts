#!/usr/bin/env bash
# =============================================================================
#  2024-02-19 - CraHan <crahan@n00.be>
# =============================================================================

# Profile
profile=${aws_profile:-"default"}

# Retrieve a list enabled AWS regions
regions=$(aws --profile $profile ec2 describe-regions --query "Regions[].RegionName" --output text --region=us-east-1)

# Data table header
rds_data="Region,RDS ID,Minor Upgrade,Multi AZ,Encryption,Backup Days,Public\n"

# Iterate over each region and RDS instance
for region in $regions; do
    instances=$(aws --profile $profile rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier,AutoMinorVersionUpgrade,MultiAZ,StorageEncrypted,BackupRetentionPeriod,PubliclyAccessible]' --output json --region $region | jq -r '.[] | @csv')

    if [ -n "$instances" ]; then
        while read -r instance; do
            rds_data+="$region,$instance\n"
        done <<< "$instances"
    fi
done

echo -e $rds_data
