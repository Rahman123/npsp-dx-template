# Unofficial Salesforce DX project template for Salesforce.org Non Profit Success Pack (NPSP)

## About
This project allow you to pre-install Salesforce.org Non Profit Success Pack (NPSP) with Salesforce DX.
Unlike the official NPSP official install procedure, this project does not require CumulusCI.

The provided install script is built using Bash but it could easily be re-written for Windows Shell (PR welcome).

This project is a personal contribution, it is not supported by Salesforce.


## Installation
Before installing, make sure that project dependencies are up to date.
Edit the `install-dev.sh` script and verify that dependencies are up to date by accessing the links in comments and checking for latest releases.
If dependencies are not up to date, please correct them in the shell file and [open an issue](https://github.com/pozil/npsp-dx-template/issues) to let us know about it.

To create a new scratch org with NPSP pre-installed, simply execute the `install-dev.sh` script.
Wait for all depencencies to be installed (a couple minutes) then, you are all set, no manual configuration required.