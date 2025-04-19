# OCI ARM Host Capacity Provisioning

This repository contains Terraform configurations and scripts to automate the provisioning of ARM-based instances on Oracle Cloud Infrastructure (OCI).

## Motivation

Oracle Cloud Infrastructure (OCI) offers Always Free ARM instances, but these resources are extremely scarce and difficult to secure. This project was created to solve this problem by:

- Automatically monitoring for available ARM capacity on OCI
- Instantly attempting to provision when resources become available
- Implementing intelligent retry mechanisms when facing "capacity not available" errors
- Reducing manual effort in repeatedly checking for and claiming free resources

With this tool, you can let the script run in the background and automatically provision an ARM instance as soon as capacity becomes available, rather than manually checking and facing disappointment.

