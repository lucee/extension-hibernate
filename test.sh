#!/usr/bin/env bash

###
# Lucee Extension Test script
# 
# To run this script, you must: 
# 1. Check out https://github.com/lucee/lucee to the parent directory: ../lucee/
# 1. Check out https://github.com/lucee/script-runner to the parent directory: ../script-runner/
###

# Path to the checked out Lucee source
# Note that the tests run are pulled from this directory,
# so you'll have best luck (up to date tests) if you check out the tag that matches the LUCEE_VERSION variable.
LUCEE_PATH="$PWD/../lucee/"

# Path to the checked out lucee/script-runner project,
# which is what sets up and runs the CFML-based tests
LUCEE_SCRIPT_RUNNER_PATH="$PWD/../script-runner/"

# Lucee version to use to run tests on
# The tests themselves, however, will be sourced from `LUCEE_PATH/test`.
# 
# Due to LDEV-3616, this must be AT LEAST 6.0.0.316 or the tests will fail with an NPE.
# @see https://luceeserver.atlassian.net/browse/LDEV-3616
LUCEE_VERSION=6.0.0.316-SNAPSHOT

# Filter by test label
export testLabels="orm"

# Filter by test "filter"
# Highly recommend NOT using this, since it's just a filename/path-based filter...
# and you will end up running undesired tests like `imageFormat` simply because of the "orm" in the filename.
export testFilter=""

# Run our local tests using the `testAdditional` environment variable.
export testAdditional="$PWD/tests"

# Ensure the current extension is compiled for testing.
if [ ! -f `echo "target/*.lex"` ]; then
    echo "Extension file not found! Cannot run tests."
    echo "Please run 'mvn clean package' to generate the .lex extension file in target/"
    exit 1;
fi

# Import .env and export to environment
# Useful for testing MSSQL, MYSQL with secret credentials
# @see https://stackoverflow.com/a/30969768
if [ -f "tests/.env" ]; then
    set -o allexport
    source tests/.env
    set +o allexport
fi

# Run the tests
ant \
    -buildfile "${LUCEE_SCRIPT_RUNNER_PATH}" \
    -DluceeVersion="$LUCEE_VERSION" \
    -Dwebroot="${LUCEE_PATH}test" \
    -Dexecute="/bootstrap-tests.cfm" \
    -DextensionDir="$PWD/target" \
    -DtestAdditional="$PWD/tests"