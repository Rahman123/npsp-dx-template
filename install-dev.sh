#!/bin/bash
# Unofficial Salesforce DX install script for Salesforce.org NonProfite Success Pack (NPSP)
# https://github.com/pozil/npsp-dx-template
# Review and update dependencies before installing

# Salesforce DX scratch org alias
ORG_ALIAS="npsp-dev"

### BEGIN DEPENDENCIES
CONTACTS_AND_ORGANIZATIONS_PACKAGE="04t80000001AWvw" # v3.11 - https://github.com/SalesforceFoundation/Contacts_and_Organizations/releases
HOUSEHOLDS_PACKAGE="04t80000000y8ty" # v3.11 - https://github.com/SalesforceFoundation/Households/releases
RECURRING_DONATIONS_PACKAGE="04t80000000gZsgAAE" # v3.13 - https://github.com/SalesforceFoundation/Recurring_Donations/releases
RELATIONSHIPS_PACKAGE="04t80000000y8kR" # v3.8 - https://github.com/SalesforceFoundation/Relationships/releases
AFFILIATIONS_PACKAGE="04t80000000lTMl" # v3.7 - https://github.com/SalesforceFoundation/Affiliations/releases
NPSP_CORE_PACKAGE="04t1Y0000011SrnQAE" # v3.143 - https://github.com/SalesforceFoundation/Cumulus/releases
NPSP_CORE_VERSION="3.143" # https://github.com/SalesforceFoundation/Cumulus/releases
### END DEPENDENCIES


echo ""
echo "Installing NPSP:"
echo "- Org alias:      $ORG_ALIAS"
echo ""

# Reset current path to be relative to script file
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

# Create scratch org
echo "Creating scratch org..." && \
sfdx force:org:create -s -f config/project-scratch-def.json -d 30 -a $ORG_ALIAS && \
echo "" && \

# Download and extract metadata dependencies to temp folder
echo "Downloading and extracting metadata dependencies..." && \
rm -fr temp && \
mkdir temp && \
cd temp && \
curl "https://github.com/SalesforceFoundation/Cumulus/archive/rel/$NPSP_CORE_VERSION.zip" -L -o npsp.zip && \
unzip npsp.zip "Cumulus-rel-$NPSP_CORE_VERSION/unpackaged/*" && \
mv "Cumulus-rel-$NPSP_CORE_VERSION/unpackaged/" cumulus && \
cd .. && \
echo "" && \

# Install dependencies
echo "Installing dependency 1/9: Opportunity record types..." && \
sfdx force:mdapi:deploy -d "temp/cumulus/pre/opportunity_record_types" -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 2/9: Contacts and organizations..." && \
sfdx force:package:install --package $CONTACTS_AND_ORGANIZATIONS_PACKAGE -w 10 --noprompt -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 3/9: Households..." && \
sfdx force:package:install --package $HOUSEHOLDS_PACKAGE -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 4/9: Recurring donations..." && \
sfdx force:package:install --package $RECURRING_DONATIONS_PACKAGE -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 5/9: Relationships..." && \
sfdx force:package:install --package $RELATIONSHIPS_PACKAGE -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 6/9: Affiliations..." && \
sfdx force:package:install --package $AFFILIATIONS_PACKAGE -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 7/9: Account record types..." && \
sfdx force:mdapi:deploy -d "temp/cumulus/pre/account_record_types" -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 8/9: Nonprofit success pack..." && \
sfdx force:package:install --package $NPSP_CORE_PACKAGE -w 10 --noprompt -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 9/9: Configuration..." && \
sfdx force:mdapi:deploy -d "temp/cumulus/config/managed" -w 10 -u $ORG_ALIAS && \
echo "" && \

# Remove temp install dir
rm -fr temp && \
echo "" && \

# Push local DX sources
echo "Pushing source..." && \
sfdx force:source:push -u $ORG_ALIAS && \
echo ""

# Get and check last exit code
EXIT_CODE="$?"
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Installation completed."
else
    echo "Installation failed."
fi
exit $EXIT_CODE
