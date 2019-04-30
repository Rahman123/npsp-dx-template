#!/bin/bash
# Unofficial Salesforce DX install script for Salesforce.org NonProfit Success Pack (NPSP)
# https://github.com/pozil/npsp-dx-template

# Salesforce DX scratch org alias
if [ "$#" -eq 1 ]; then
  ORG_ALIAS="$1"
else
  echo "NPSP install failed: missing org alias parameter"
  exit -1
fi

echo ""
echo "Installing NPSP on org $ORG_ALIAS"
echo ""

# Gets the latest version of a GitHub repository
# Usage:    getLatestVersion repo
# Example:  getLatestVersion SalesforceFoundation/Cumulus
getLatestVersion() {
  VERSION="$(curl -s "https://api.github.com/repos/$1/releases/latest" | jq -r .name)"
  echo $VERSION
}

# Get the Salesforce package Id (04t....) from the latest version of a GitHub repository
# Usage:    getLatestPackageId repo
# Example:  getLatestPackageId SalesforceFoundation/Cumulus
getLatestPackageId() {
  VERSION="$(curl -s "https://api.github.com/repos/$1/releases/latest" | jq .body)"
  re="installPackage\.apexp\?p0=(04t[a-zA-Z0-9]+)[\\\r\\\n|\"]"
  if [[ $VERSION =~ $re ]]; then
    echo ${BASH_REMATCH[1]};
  else
    echo "Could not extract package Id from repo: $REPO"
    exit -1;
  fi
}

### BEGIN DEPENDENCIES
CONTACTS_AND_ORGANIZATIONS_PACKAGE="$(getLatestPackageId SalesforceFoundation/Contacts_and_Organizations)"
HOUSEHOLDS_PACKAGE="$(getLatestPackageId SalesforceFoundation/Households)"
RECURRING_DONATIONS_PACKAGE="$(getLatestPackageId SalesforceFoundation/Recurring_Donations)"
RELATIONSHIPS_PACKAGE="$(getLatestPackageId SalesforceFoundation/Relationships)"
AFFILIATIONS_PACKAGE="$(getLatestPackageId SalesforceFoundation/Affiliations)"
NPSP_CORE_PACKAGE="$(getLatestPackageId SalesforceFoundation/Cumulus)"
NPSP_CORE_VERSION="$(getLatestVersion SalesforceFoundation/Cumulus)"
### END DEPENDENCIES

echo "Dependencies (automatically fetched from GitHub):"
echo ""
echo "  Contacts and Organizations $CONTACTS_AND_ORGANIZATIONS_PACKAGE"
echo "  Households $HOUSEHOLDS_PACKAGE"
echo "  Recurring Donations $RECURRING_DONATIONS_PACKAGE"
echo "  Relationships $RELATIONSHIPS_PACKAGE"
echo "  Affiliations $AFFILIATIONS_PACKAGE"
echo "  Cumulus $NPSP_CORE_PACKAGE ($NPSP_CORE_VERSION)"
echo ""

# Reset current path to be relative to script file
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

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

# With Step 8 installing the npsp managed package, this updates the token with the prefix
find temp/cumulus/post/first -type f -exec sed -i '' -e "s/%%%NAMESPACE%%%/npsp__/g" {} \;

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

echo "Installing dependency 9/9: Post NPSP Configuration..." && \
sfdx force:mdapi:deploy -d "temp/cumulus/post/first" -w 10 -u $ORG_ALIAS && \
echo "" && \

# Remove temp install dir
rm -fr temp && \
echo ""

# Get and check last exit code
EXIT_CODE="$?"
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "NPSP installation completed."
else
  echo "NPSP installation failed."
fi
exit $EXIT_CODE
