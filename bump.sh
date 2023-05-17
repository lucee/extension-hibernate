#!/usr/bin/env bash

###
# Version bump assistance script.
# 
# Feel free to use via ./bump.sh v5.4.2923 OR copy/pasting commands to use manually.
###

VERSION=$1

git checkout master
git pull
git merge development

# Bump build number
git checkout -- build.number
echo "Releasing `ant -silent -quiet version`!"

# Commit stuffs
git add build.number
git add CHANGELOG.md
git commit -m "🚀 RELEASE: $VERSION"

# tag and push to trigger a build and forgebox publish
git tag -a $VERSION -m "$VERSION"
git push
git push --tags