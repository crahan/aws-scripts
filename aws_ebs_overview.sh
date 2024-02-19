#!/usr/bin/env bash
# =============================================================================
#  2024-02-19 - CraHan <crahan@n00.be>
# =============================================================================

# Profile
profile=${aws_profile:-"default"}

# Retrieve a list enabled AWS regions
regions=$(aws --profile $profile ec2 describe-regions --query "Regions[].RegionName" --output text --region=us-east-1)

# Data table header
ebs_data="Region,Instance ID,Volume ID,Encrypted\n"

# Iterate over each EC2 instance and volume
for region in $regions; do
    for instance in $(aws --profile $profile ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --region $region --output text); do
        for volume in $(aws --profile $profile ec2 describe-instances --instance-ids $instance --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId' --region $region --output text); do
            encrypted=$(aws --profile $profile ec2 describe-volumes --volume-ids $volume --query 'Volumes[].Encrypted' --region=$region --output text)
            ebs_data+="$region,$instance,$volume,$encrypted\n"
        done
    done
done

echo -e $ebs_data
