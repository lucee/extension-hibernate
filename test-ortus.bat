SET "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-11.0.29.7-hotspot"
set testLabels=orm
set testFilter=
set testAdditional=d:\work\lucee-extensions\extension-hibernate\tests
set testServices=mysql,mssql


call ant -buildfile "d:\work\script-runner" -DluceeVersion="6.2/snapshot/light" -Dwebroot="d:\work\lucee7" -Dexecute="test\bootstrap-tests.cfm" -Dextensions="D062D72F-F8A2-46F0-8CBC91325B2F067B" -DuniqueWorkingDir="true"

call ant -buildfile "d:\work\script-runner" -DluceeVersion="7.0/snapshot/light" -Dwebroot="d:\work\lucee7" -Dexecute="test\bootstrap-tests.cfm" -Dextensions="D062D72F-F8A2-46F0-8CBC91325B2F067B" -DuniqueWorkingDir="true"


call ant -buildfile "d:\work\script-runner" -DluceeVersion="7.1/snapshot/light" -Dwebroot="d:\work\lucee7" -Dexecute="test\bootstrap-tests.cfm" -Dextensions="D062D72F-F8A2-46F0-8CBC91325B2F067B" -DuniqueWorkingDir="true"