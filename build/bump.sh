#!/usr/bin/env bash

###
# Version bump assistance script.
# 
# Feel free to use via ./bump.sh v5.4.29.23 OR copy/pasting commands to use manually.
###

NEW_VERSION=$1
OLD_VERSION=`mvn help:evaluate -f ../pom.xml -Dexpression=project.version -q -DforceStdout`

# Bump version number
echo "Setting version=${NEW_VERSION} in pom.xml..."
git checkout -- pom.xml
sed -i -e "s/$OLD_VERSION/$NEW_VERSION/g" pom.xml

git add pom.xml box.json
git commit -m "🚀 RELEASE: Begin development on $NEW_VERSION"