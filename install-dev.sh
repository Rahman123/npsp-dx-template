#!/bin/bash

# Set parameters
ORG_ALIAS="npsp-dev"

### BEGIN DEPENDENCIES
CONTACTS_AND_ORGANIZATIONS="04t80000001AWvw" # v3.11 - https://github.com/SalesforceFoundation/Contacts_and_Organizations/releases
HOUSEHOLDS="04t80000000y8ty" # v3.11 - https://github.com/SalesforceFoundation/Households/releases
RECURRING_DONATIONS="04t80000000gZsgAAE" # v3.13 - https://github.com/SalesforceFoundation/Recurring_Donations/releases
RELATIONSHIPS="04t80000000y8kR" # v3.8 - https://github.com/SalesforceFoundation/Relationships/releases
AFFILIATIONS="04t80000000lTMl" # v3.7 - https://github.com/SalesforceFoundation/Affiliations/releases
NONPROFIT_SUCCESS_PACK="04t1Y0000011SrnQAE" # v3.143 - https://github.com/SalesforceFoundation/Cumulus/releases
SALESFORCE1_CONFIG="https://github.com/SalesforceFoundation/Cumulus/releases/download/rel/1.7/sf1.zip"
NONPROFIT_SUCCESS_PACK_VERSION="3.143"
### END DEPENDENCIES


echo ""
echo "Installing NPSP:"
echo "- Org alias:      $ORG_ALIAS"
echo ""

# Create scratch org
echo "Creating scratch org..." && \
sfdx force:org:create -s -f config/project-scratch-def.json -d 30 -a $ORG_ALIAS && \
echo "" && \

# Reset current path to be relative to script file
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

# Download metadata dependencies to temp folder
echo "Downloading and unpacking dependencies..." && \
rm -fr temp && \
mkdir temp && \
cd temp && \
curl "https://github.com/SalesforceFoundation/Cumulus/archive/rel/$NONPROFIT_SUCCESS_PACK_VERSION.zip" -L -o npsp.zip && \
unzip npsp.zip "Cumulus-rel-$NONPROFIT_SUCCESS_PACK_VERSION/unpackaged/*" && \
mv "Cumulus-rel-$NONPROFIT_SUCCESS_PACK_VERSION/unpackaged/" cumulus && \
curl $SALESFORCE1_CONFIG -L -o sf1.zip && \
unzip sf1.zip -d sf1 && \
cd .. && \
echo "" && \

# Install dependencies
echo "Installing dependency 1/10: Opportunity record types..." && \
sfdx force:mdapi:deploy -d "temp/cumulus/pre/opportunity_record_types" -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 2/10: Contacts and organizations..." && \
sfdx force:package:install --package $CONTACTS_AND_ORGANIZATIONS -w 10 --noprompt -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 3/10: Households..." && \
sfdx force:package:install --package $HOUSEHOLDS -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 4/10: Recurring donations..." && \
sfdx force:package:install --package $RECURRING_DONATIONS -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 5/10: Relationships..." && \
sfdx force:package:install --package $RELATIONSHIPS -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 6/10: Affiliations..." && \
sfdx force:package:install --package $AFFILIATIONS -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 7/10: Account record types..." && \
sfdx force:mdapi:deploy -d "temp/cumulus/pre/account_record_types" -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 8/10: Nonprofit success pack..." && \
sfdx force:package:install --package $NONPROFIT_SUCCESS_PACK -w 10 --noprompt -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 9/10: Salesforce1 configuration..." && \
sfdx force:mdapi:deploy -d "temp/sf1" -w 10 -u $ORG_ALIAS && \
echo "" && \

echo "Installing dependency 10/10: Configuration..." && \
sfdx force:mdapi:deploy -d post-install-config -w 10 -u $ORG_ALIAS && \
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
