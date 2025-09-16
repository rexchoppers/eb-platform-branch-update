#!/bin/bash

# Global variables (empty to start with)
access_key_id=""
secret_access_key=""
region=""
app_name=""
platform=""

# Dialogue to ask for AWS credentials and region, then configure AWS CLI
configure_aws() {
  # If any dialog is canceled (non-zero exit), return to home
  # Note: 'home' is defined in home.sh and this file is sourced by main.sh alongside home.sh
  access_key_id=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Access Key ID:" 8 50) || { home; return; }

  secret_access_key=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Secret Access Key:" 8 50) || { home; return; }

  region=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Region (e.g., us-west-2):" 8 50) || { home; return; }

  # Configure AWS CLI with the provided credentials and region
  aws configure set aws_access_key_id "$access_key_id"
  aws configure set aws_secret_access_key "$secret_access_key"
  aws configure set region "$region"

  # Run aws sts get-caller-identity to verify configuration
  if aws sts get-caller-identity >/tmp/aws_verify 2>&1; then
    dialog --title "AWS CLI: Success" \
           --msgbox "Credentials verified successfully!\n\n$(cat /tmp/aws_verify)" 15 70
  else
    dialog --title "AWS CLI: Error" \
           --msgbox "Failed to verify credentials.\n\n$(cat /tmp/aws_verify)" 15 70
    configure_aws
  fi

  rm -f /tmp/aws_verify
}

configure_eb() {
  app_name=$(dialog --clear --stdout \
    --title "EB CLI: Configuration" \
    --inputbox "Enter your Elastic Beanstalk Application Name:" 8 50) || { home; return; }

  platform=$(dialog --clear --stdout \
    --title "EB CLI: Configuration" \
    --inputbox "Enter the Platform (e.g., node.js, python, docker):" 8 50) || { home; return; }

  # Capture EB CLI output/errors
  if output=$(eb init "$app_name" --region "$region" --platform "$platform" 2>&1); then
    dialog --title "EB CLI" --msgbox "Elastic Beanstalk configured successfully" 8 50
    select_version
  else
    dialog --title "EB CLI: Error" --msgbox "Failed to configure EB.\n\n$output" 15 70
  fi
}
