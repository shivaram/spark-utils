#!/bin/bash

function exit_with_usage {
  cat << EOF
usage: tag-release.sh
Tags a Spark release on a particular branch.

Inputs are specified with the following environment variables:
ASF_USERNAME - Apache Username
ASF_PASSWORD - Apache Password
GIT_NAME - Name to use with git
GIT_EMAIL - E-mail address to use with git
GIT_BRANCH - Git branch on which to make release
RELEASE_VERSION - Version used in pom files for release
RELEASE_TAG - Name of release tag
NEXT_VERSION - Development version after release
EOF
  exit 1
}

set -e

if [[ $@ == *"help"* ]]; then
  exit_with_usage
fi

for env in ASF_USERNAME ASF_PASSWORD RELEASE_VERSION RELEASE_TAG NEXT_VERSION GIT_EMAIL GIT_NAME GIT_BRANCH; do
  if [ -z "${!env}" ]; then
    echo "$env must be set to run this script"
    exit 1
  fi
done

ASF_SPARK_REPO="git-wip-us.apache.org/repos/asf/spark.git"

rm -rf spark
git clone https://$ASF_USERNAME:$ASF_PASSWORD@$ASF_SPARK_REPO -b $GIT_BRANCH
cd spark

git config user.name "$GIT_NAME"
git config user.email $GIT_EMAIL

# Create release version
mvn versions:set -DnewVersion=$RELEASE_VERSION | grep -v "no value" # silence logs
git commit -a -m "Preparing Spark release $RELEASE_TAG"
echo "Creating tag $RELEASE_TAG at the head of $GIT_BRANCH"
git tag $RELEASE_TAG

# TODO: It would be nice to do some verifications here
#       i.e. check whether ec2 scripts have the new version

# Create next version
mvn versions:set -DnewVersion=$NEXT_VERSION | grep -v "no value" # silence logs
git commit -a -m "Preparing development version $NEXT_VERSION"

# Push changes
git push origin $RELEASE_TAG
git push origin HEAD:$GIT_BRANCH

cd ..
rm -rf spark
