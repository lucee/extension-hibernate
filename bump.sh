#!/usr/bin/env bash

###
# Version bump assistance script.
# 
# Feel free to use via ./bump.sh v5.4.29.23 OR copy/pasting commands to use manually.
###

NEW_VERSION=$1
OLD_VERSION=`mvn help:evaluate -Dexpression=project.version -q -DforceStdout`

echo "Merging development to master..."
git checkout master
git pull
git merge development

# Bump version number
echo "Setting version=${NEW_VERSION} in pom.xml and box.json..."
git checkout -- pom.xml box.json
sed -i -e "s/$OLD_VERSION/$NEW_VERSION/g" pom.xml
box package set version=$NEW_VERSION

# Commit version updates
echo "Committing version update and changelog..."
git add pom.xml box.json
git add CHANGELOG.md
git commit -m "🚀 RELEASE: $NEW_VERSION"

# tag and push to trigger a build and forgebox publish
echo "Creating and pushing tag..."
git tag -a "v$NEW_VERSION" -m "🚀 RELEASE: $NEW_VERSION"
git push
git push --tags

echo "🚀🚀🚀 Done! Your release is now building on github."