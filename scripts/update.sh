#!/bin/bash

# Global variables
access_key_id=""
secret_access_key=""
region=""
app_name=""
platform=""
env_name=""
current_platform_arn=""

timestamp=$(date +"%Y%m%d%H%M%S")

# Master flow
update() {
  configure_aws        || { home; return; }
  select_eb_application || { home; return; }
  select_eb_platform    || { home; return; }
  configure_eb          || { home; return; }
  select_eb_environment || { home; return; }
  download_config     || { home; return; }
  extract_current_platform_arn || { home; return; }
  select_new_platform_version || { home; return; }
}

select_new_platform_version() {
  versions=$(AWS_PAGER="" aws elasticbeanstalk list-platform-versions \
    --query "PlatformSummaryList[].PlatformArn" \
    --output json 2>/tmp/eb_versions_error)

  if [ $? -ne 0 ] || [ -z "$versions" ]; then
    dialog --title "EB CLI: Error" \
           --msgbox "Could not fetch platform versions.\n\n$(cat /tmp/eb_versions_error)" 12 70
    rm -f /tmp/eb_versions_error
    return 1
  fi
  rm -f /tmp/eb_versions_error

  # Parse JSON array into Bash array safely
  mapfile -t version_array < <(echo "$versions" | jq -r '.[]')

  # Build menu items: show only stripped name; selection maps to full ARN
  declare -A version_map
  declare -A seen
  version_menu=()
  for idx in "${!version_array[@]}"; do
    full="${version_array[$idx]}"
    # Human-readable name (without ARN prefix) — everything after ::platform/
    name="${full##*::platform/}"

    # Use the display name as the tag. Handle potential duplicates by appending a minimal suffix.
    tag="$name"
    if [[ -n "${seen[$tag]}" ]]; then
      suffix=2
      # Find a suffix that makes the tag unique
      while [[ -n "${seen["$name ($suffix)"]}" ]]; do
        ((suffix++))
      done
      tag="$name ($suffix)"
      seen["$tag"]=1
    else
      seen["$tag"]=1
    fi

    version_map["$tag"]="$full"
    # Use the same name as description so the dialog shows only the readable name.
    version_menu+=("$tag" "$name")
  done

  # Compute menu-height
  menu_height=${#version_array[@]}
  ((menu_height>10)) && menu_height=10

  selected_display=$(dialog --clear --stdout \
    --title "Select EB Platform Version" \
    --menu "Choose an Elastic Beanstalk Platform Version:" 20 120 "$menu_height" \
    "${version_menu[@]}") || return 1

  # Map back to full ARN
  selected_version="${version_map[$selected_display]}"

  dialog --title "EB CLI" --msgbox "Selected Platform Version:\n$selected_version" 8 120
  return 0
}



# Extract current platform ARN from downloaded config
extract_current_platform_arn() {
  current_platform_arn=$(awk '
    $1 == "PlatformArn:" {
      val=$2;
      for (i=3; i<=NF; i++) val=val " " $i;
      getline;
      while ($1 == "" || $1 ~ /^Amazon/) {  # continuation lines
        for (i=1; i<=NF; i++) val=val " " $i;
        getline;
      }
      print val;
      exit
    }' ".elasticbeanstalk/saved_configs/$env_name-$timestamp.cfg.yml")

  if [ -n "$current_platform_arn" ]; then
    dialog --title "EB CLI" \
           --msgbox "Current Platform ARN:\n$current_platform_arn" 10 70
    return 0
  else
    dialog --title "EB CLI: Error" \
           --msgbox "Could not extract Platform ARN from configuration." 10 70
    return 1
  fi
}

# Download configuration file from EB environment
download_config() {
  dialog --title "EB CLI" --infobox "Downloading configuration for $env_name...\nPlease wait." 6 60
  sleep 1

  if output=$(eb config save "$env_name" --cfg "$env_name-$timestamp" 2>&1); then
    dialog --title "EB CLI" \
           --infobox "Configuration downloaded.\nSaved as: $env_name-$timestamp.cfg.yml" 6 60
    sleep 2
    return 0
  else
    dialog --title "EB CLI: Error" \
           --msgbox "Failed to save configuration.\n\n$output" 15 70
    return 1
  fi
}


# AWS credentials
configure_aws() {
  access_key_id=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Access Key ID:" 8 50) || return 1

  secret_access_key=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Secret Access Key:" 8 50) || return 1

  region=$(dialog --clear --stdout \
    --title "AWS CLI: Configuration" \
    --inputbox "Enter your AWS Region (e.g., us-west-2):" 8 50) || return 1

  aws configure set aws_access_key_id "$access_key_id"
  aws configure set aws_secret_access_key "$secret_access_key"
  aws configure set region "$region"

  if aws sts get-caller-identity >/tmp/aws_verify 2>&1; then
    dialog --title "AWS CLI: Success" \
           --msgbox "Credentials verified successfully!\n\n$(cat /tmp/aws_verify)" 15 70
    rm -f /tmp/aws_verify
    return 0
  else
    dialog --title "AWS CLI: Error" \
           --msgbox "Failed to verify credentials.\n\n$(cat /tmp/aws_verify)" 15 70
    rm -f /tmp/aws_verify
    return 1
  fi
}

# Select EB application
select_eb_application() {
  apps=$(aws elasticbeanstalk describe-applications \
    --query "Applications[].ApplicationName" \
    --output text 2>/tmp/eb_apps_error)

  if [ $? -ne 0 ] || [ -z "$apps" ]; then
    dialog --title "EB CLI: Error" \
           --msgbox "Could not fetch applications.\n\n$(cat /tmp/eb_apps_error)" 12 70
    rm -f /tmp/eb_apps_error
    return 1
  fi
  rm -f /tmp/eb_apps_error

  app_menu=()
  for app in $apps; do
    app_menu+=("$app" "Elastic Beanstalk Application")
  done

  app_name=$(dialog --clear --stdout \
    --title "Select EB Application" \
    --menu "Choose an Elastic Beanstalk Application:" 15 60 5 \
    "${app_menu[@]}") || return 1

  dialog --title "EB CLI" --msgbox "Selected Application: $app_name" 8 50
  return 0
}

# Select EB platform
select_eb_platform() {
  platforms=$(eb platform list --region "$region" 2>/tmp/eb_platforms_error | grep -v "^\s*$")
  if [ $? -ne 0 ] || [ -z "$platforms" ]; then
    dialog --title "EB CLI: Error" \
           --msgbox "Could not fetch platforms.\n\n$(cat /tmp/eb_platforms_error)" 12 70
    rm -f /tmp/eb_platforms_error
    return 1
  fi
  rm -f /tmp/eb_platforms_error

  platform_menu=()
  while IFS= read -r plat; do
    platform_menu+=("$plat" "")
  done <<< "$platforms"

  platform=$(dialog --clear --stdout \
    --title "Select EB Platform" \
    --menu "Choose an Elastic Beanstalk Platform:" 20 90 15 \
    "${platform_menu[@]}") || return 1

  dialog --title "EB CLI" --msgbox "Selected Platform: $platform" 8 50
  return 0
}

# Select EB environment
select_eb_environment() {
  envs=$(aws elasticbeanstalk describe-environments \
    --application-name "$app_name" \
    --query "Environments[].EnvironmentName" \
    --output text 2>/tmp/eb_envs_error)

  if [ $? -ne 0 ] || [ -z "$envs" ]; then
    dialog --title "EB CLI: Error" \
           --msgbox "Could not fetch environments for application: $app_name\n\n$(cat /tmp/eb_envs_error)" 12 70
    rm -f /tmp/eb_envs_error
    return 1
  fi
  rm -f /tmp/eb_envs_error

  env_menu=()
  for env in $envs; do
    env_menu+=("$env" "Environment in $app_name")
  done

  env_name=$(dialog --clear --stdout \
    --title "Select EB Environment" \
    --menu "Choose an Elastic Beanstalk Environment:" 15 70 5 \
    "${env_menu[@]}") || return 1

  dialog --title "EB CLI" --msgbox "Selected Environment: $env_name" 8 50
  return 0
}

# Run EB init
configure_eb() {
  if output=$(eb init "$app_name" --region "$region" --platform "$platform" 2>&1); then
    dialog --title "EB CLI" --msgbox "Elastic Beanstalk configured successfully" 8 50
    return 0
  else
    dialog --title "EB CLI: Error" --msgbox "Failed to configure EB.\n\n$output" 15 70
    return 1
  fi
}
