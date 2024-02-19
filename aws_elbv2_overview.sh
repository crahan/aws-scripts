#!/usr/bin/env bash
# =============================================================================
#  2024-02-19 - CraHan <crahan@n00.be>
# =============================================================================

# Profile
profile=${aws_profile:-"default"}

# Retrieve a list enabled AWS regions
regions=$(aws --profile $profile ec2 describe-regions --query "Regions[].RegionName" --output text --region=us-east-1)

# Data table header
elbv2_data="Region,Name,Type,DNS,Proto,Port,Action\n"

# Iterate over each region and load balancer
for region in $regions; do
    lbs_info=$(aws --profile $profile elbv2 describe-load-balancers --region "$region" 2>/dev/null | jq -r '.LoadBalancers[] | "\(.LoadBalancerName)\t\(.Type)\t\(.LoadBalancerArn)\t\(.DNSName)"')

    if [ -n "$lbs_info" ]; then
        while read -r lb_info; do
            lb_name=$(echo "$lb_info" | awk '{print $1}')
            lb_type=$(echo "$lb_info" | awk '{print substr($2, 1, 3)}')
            lb_arn=$(echo "$lb_info" | awk '{print $3}')
            lb_dns=$(echo "$lb_info" | awk '{print $4}')
            listeners=$(aws --profile $profile elbv2 describe-listeners --load-balancer-arn "$lb_arn" --region "$region" --query 'Listeners[].[Protocol,Port,DefaultActions[].Type]' | jq -r '.[] | [.[0], .[1], .[2][]] | @csv')

            while read -r listener; do
                elbv2_data+="$region,$lb_name,$lb_type,$lb_dns,$listener\n"
            done <<< "$listeners"
        done <<< "$lbs_info"
    fi
done

echo -e $elbv2_data
