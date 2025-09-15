#!/bin/bash

# Dialogue to ask for AWS credentials and region, then configure AWS CLI
configure_aws() {
  # Prompt for AWS Access Key ID
  access_key_id=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Access Key ID:" 8 50)

  # Prompt for AWS Secret Access Key
  secret_access_key=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Secret Access Key:" 8 50)

  # Prompt for AWS Region
  region=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Region (e.g., us-west-2):" 8 50)

  # Configure AWS CLI with the provided credentials and region
  aws configure set aws_access_key_id "$access_key_id"
  aws configure set aws_secret_access_key "$secret_access_key"
  aws configure set region "$region"

  dialog --title "Configuration Complete" \
         --msgbox "AWS CLI has been configured successfully." 8 50
}
