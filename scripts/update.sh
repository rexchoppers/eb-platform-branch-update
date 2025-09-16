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

    rm -f /tmp/aws_verify
    configure_eb
  else
    dialog --title "AWS CLI: Error" \
           --msgbox "Failed to verify credentials.\n\n$(cat /tmp/aws_verify)" 15 70

    rm -f /tmp/aws_verify
    configure_aws
  fi
}

configure_eb() {
  # Let user select EB Application first
  select_eb_application || return

  # Then ask for Platform
  platform=$(dialog --clear --stdout \
    --title "EB CLI: Configuration" \
    --inputbox "Enter the Platform (e.g., node.js, python, docker):" 8 50) || { home; return; }

  # Capture EB CLI output/errors
  if output=$(eb init "$app_name" --region "$region" --platform "$platform" 2>&1); then
    dialog --title "EB CLI" --msgbox "Elastic Beanstalk configured successfully" 8 50

  else
    dialog --title "EB CLI: Error" --msgbox "Failed to configure EB.\n\n$output" 15 70
  fi
}

select_eb_application() {
  # Get applications from Elastic Beanstalk
  apps=$(aws elasticbeanstalk describe-applications \
    --query "Applications[].ApplicationName" \
    --output text 2>/tmp/eb_apps_error)

  if [ $? -ne 0 ] || [ -z "$apps" ]; then
    dialog --title "EB CLI: Error" \
           --msgbox "Could not fetch applications.\n\n$(cat /tmp/eb_apps_error)" 12 70
    rm -f /tmp/eb_apps_error
    home
    return 1
  fi
  rm -f /tmp/eb_apps_error

  # Build menu options (label + description pairs)
  app_menu=()
  for app in $apps; do
    app_menu+=("$app" "Elastic Beanstalk Application")
  done

  # Show dialog menu
  app_name=$(dialog --clear --stdout \
    --title "Select EB Application" \
    --menu "Choose an Elastic Beanstalk Application:" 15 60 5 \
    "${app_menu[@]}") || { home; return 1; }

  if [ -n "$app_name" ]; then
    dialog --title "EB CLI" \
           --msgbox "Selected Application: $app_name" 8 50
  else
    home
    return 1
  fi
}
