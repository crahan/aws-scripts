# aws-scripts

Shell scripts to retrieve high-level details across all enabled AWS regions for:

- `aws_ebs_overview.sh`: EBS volume encryption status.
- `aws_ec2_overview.sh`: EC2 instance ID, instance name, running state, VPC ID, IMDS status, IMDS token requirement, public DNS name, public IP address, and IAM role.
- `aws_elbv2_overview.sh`: Load balancer name, type, DNS name, protocol, port, and action.
- `aws_lambda_download.sh`: Downloads all Lambda function sourcer code from S3 buckets.
- `aws_rds_overview.sh`: RDS instance ID, minor upgrade, multi AZ, encryption, backup days, public.
- `aws_s3_overview.sh`: S3 bucket name, HTTPS enforcement, versioning, logging, encryption.

The scripts use the `aws_profile` environment as the profile name when running `aws` commands. If missing, it falls back to `default`.
