#!/usr/bin/env bash
# =============================================================================
#  2024-02-19 - CraHan <crahan@n00.be>
# =============================================================================

# Profile
profile=${aws_profile:-"default"}

# Retrieve a list enabled AWS regions
regions=$(aws --profile $profile ec2 describe-regions --query "Regions[].RegionName" --output text --region=us-east-1)

for region in $regions; do
    fnames=$(aws --profile $profile lambda list-functions --region $region --query 'Functions[*].FunctionName' --output text);

    for fname in $fnames; do
        echo "Downloading $region-$fname.zip";
        url=$(aws --profile $profile lambda get-function --region $region --function-name $fname | jq .Code.Location | sed s/\"//g);
        curl -s "$url" -o $region-$fname.zip;
    done;
done
