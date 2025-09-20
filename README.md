# EB Platform Branch Update

Interactive terminal tool to help you update the Platform Branch for an AWS Elastic Beanstalk environment by generating and pushing a new saved configuration template. It uses a simple TUI (dialog) to guide you through selecting the application, platform, environment, and target platform version.

## History
Elastic Beanstalk environments are tied to a specific platform version (e.g., "64bit Amazon Linux 2 v3.4.10 running Python 3.8"). AWS periodically releases new platform versions, including security updates and new features. However, if you need to update the Platform Branch, you must create a new environment or manually change the platform version via the EB Console or EB CLI.

This requires cloning and re-configuring the environment, which can be error-prone and time-consuming. This tool simplifies the process by automating the creation of a new saved configuration with the updated PlatformArn, which you can then apply to your environment.

## Warning
When creating a new environment from a configuration file, there are some parts of the configuration that are not copied over. The issue I'm aware of so far are:

- Not copying VPC settings (subnets, security groups, ELB type, etc.). If your environment is in a VPC, you will need to manually reconfigure these settings after applying the new configuration.
- Instance type is not copied over

## What it does
- Asks for AWS credentials and region, configures the default AWS CLI profile, and verifies identity.
- Lists Elastic Beanstalk Applications, Platforms, and Environments for selection.
- Saves the current environment configuration and extracts the existing PlatformArn.
- Lists available Elastic Beanstalk platform versions to choose from.
- Creates a new saved configuration with the updated PlatformArn and pushes it to EB.

You can then create a new environment using the new saved configuration.

## Requirements
- Docker

To ensure a consistent environment, using the provided Dockerfile is recommended.

## TODO

- Deploy image
- Run with Docker

## Links
- Contributing: see `CONTRIBUTING.md`
- Changelog: see `CHANGELOG.md`
- License: see `LICENSE`

