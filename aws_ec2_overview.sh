#!/usr/bin/env bash
# =============================================================================
#  2024-02-19 - CraHan <crahan@n00.be>
# =============================================================================

# Profile
profile=${aws_profile:-"default"}

# Retrieve a list enabled AWS regions
regions=$(aws --profile $profile ec2 describe-regions --query "Regions[].RegionName" --output text --region=us-east-1)

# Data table header
ec2_data="Region,Instance ID,Instance Name,State,VPC ID,IMDS State,IMDS Token,Public DNS Name,Public IP,Instance Profile ARN\n"

# Iterate over each region and EC2 instance
for region in $regions; do
    ec2s_info=$(aws --profile $profile ec2 describe-instances --region $region --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name'].Value | [0],State.Name,VpcId,MetadataOptions.HttpEndpoint,MetadataOptions.HttpTokens,PublicDnsName,PublicIpAddress,IamInstanceProfile.Arn]" --output text)

    if [ -n "$ec2s_info" ]; then
        while read -r ec2_info; do
            ec2_id=$(echo "$ec2_info" | awk '{print $1}')
            ec2_name=$(echo "$ec2_info" | awk '{print $2}')
            ec2_state=$(echo "$ec2_info" | awk '{print $3}')
            ec2_vpc=$(echo "$ec2_info" | awk '{print $4}')
            ec2_imds_state=$(echo "$ec2_info" | awk '{print $5}')
            ec2_imds_token=$(echo "$ec2_info" | awk '{print $6}')
            ec2_dns=$(echo "$ec2_info" | awk '{print $7}')
            ec2_pubip=$(echo "$ec2_info" | awk '{print $8}')
            ec2_profilearn=$(echo "$ec2_info" | awk '{print $9}')
            ec2_role="-"

            if [ "$ec2_profilearn" != "None" ]; then
                ec2_role=$(aws --profile $profile iam get-instance-profile --instance-profile-name $(basename $ec2_profilearn) --query 'InstanceProfile.Roles[0].RoleName' --output text --region=$region 2>/dev/null)
            fi

            ec2_data+="$region,$ec2_id,$ec2_name,$ec2_state,$ec2_vpc,$ec2_imds_state,$ec2_imds_token,$ec2_dns,$ec2_pubip,$ec2_role\n"
        done <<< "$ec2s_info"
    fi
done

echo -e $ec2_data
