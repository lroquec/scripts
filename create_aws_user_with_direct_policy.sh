#!/usr/bin/env bash
set -euo pipefail

# Variables you can edit before running the script
USERNAME="eksadmin1"
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"
REGION="us-east-1"
OUTPUT_FORMAT="json"
create_aws_cli_config="false"  # Set this to "true" to generate AWS CLI configuration steps.
eks_user="false"  # Set this to "true" if you want to print EKS ConfigMap snippet.

# Generate a random password using openssl (12 bytes -> longer base64 string)
# Feel free to change the length according to your security requirements.
PASSWORD=$(openssl rand -base64 12)

echo "Generated password: $PASSWORD"

# 1. Create the IAM user
# The user is created with no permissions initially.
echo "Creating IAM user: $USERNAME"
aws iam create-user --user-name "$USERNAME" >/dev/null

# 2. Attach the specified policy to the user
# In this case, we're attaching AdministratorAccess.
echo "Attaching policy $POLICY_ARN to user $USERNAME"
aws iam attach-user-policy --policy-arn "$POLICY_ARN" --user-name "$USERNAME" >/dev/null

# 3. Set a login profile (password) for the new user
# This allows the user to log in to the AWS Management Console.
# Add --no-password-reset-required to disable password reset on first login.
echo "Creating login profile for user $USERNAME"
aws iam create-login-profile --user-name "$USERNAME" --password "$PASSWORD" >/dev/null

# 4. Create an access key for the user
# This will allow programmatic access via AWS CLI/SDK.
echo "Creating access key for user $USERNAME"
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name "$USERNAME")
ACCESS_KEY_ID=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo "$ACCESS_KEY_OUTPUT" | jq -r '.AccessKey.SecretAccessKey')

echo "AccessKeyId obtained: $ACCESS_KEY_ID"
echo "SecretAccessKey obtained: $SECRET_ACCESS_KEY"

# 5 & 6. Conditionally configure AWS CLI and verify
if [ "$create_aws_cli_config" = "true" ]; then
    # Configure the new AWS CLI profile using the generated credentials
    # We use `aws configure set` to avoid interactive input.
    echo "Configuring AWS CLI profile for user $USERNAME"
    aws configure set aws_access_key_id "$ACCESS_KEY_ID" --profile "$USERNAME"
    aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY" --profile "$USERNAME"
    aws configure set region "$REGION" --profile "$USERNAME"
    aws configure set output "$OUTPUT_FORMAT" --profile "$USERNAME"

    # Verification steps
    # List current configuration and profiles to ensure changes are applied.
    echo "Listing current configuration:"
    aws configure list

    echo "Listing available profiles:"
    aws configure list-profiles
else
    echo "Skipping AWS CLI configuration steps as create_aws_cli_config is not true."
fi

# If eks_user is true, print out the ConfigMap snippet
if [ "$eks_user" = "true" ]; then
    # Retrieve the IAM User ARN
    USER_ARN=$(aws iam get-user --user-name "$USERNAME" | jq -r '.User.Arn')

    echo "Add the following snippet to your EKS cluster's aws-auth ConfigMap:"
    echo "## mapUsers TEMPLATE - Replace with IAM User ARN and USERNAME"
    echo "mapUsers: |"
    echo "  - userarn: $USER_ARN"
    echo "    username: $USERNAME"
    echo "    groups:"
    echo "      - system:masters"
fi

echo "Process completed successfully."
echo "Please save the AccessKeyId and SecretAccessKey in a secure location."