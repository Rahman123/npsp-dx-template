# Unofficial Salesforce DX project template for Salesforce.org Non Profit Success Pack (NPSP)

## About
This project allow you to pre-install Salesforce.org Non Profit Success Pack (NPSP) with Salesforce DX.<br/>
Unlike the official NPSP official install procedure, this project does not require CumulusCI.

This project is a personal contribution, it is not supported by Salesforce.

## Requirements
- The script is built using Bash but it could be re-written for Windows Shell (PR welcome).
- The script requires [jq](https://stedolan.github.io/jq/) to parse json from the command-line

## Installation
To create a new scratch org with the latest stable version of NPSP pre-installed, simply execute the `install-dev.sh` script.
Wait for all depencencies to be installed (a couple minutes) then, you are all set, no manual configuration other than layout tweaking required.

Note: latest dependencies are automatically fetched from GitHub.