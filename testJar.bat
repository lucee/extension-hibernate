SET "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot"
call mvn verify
if %errorlevel% neq 0 exit /b %errorlevel%
set testLabels=orm
set testFilter=%~2
set testAdditional=d:\work\lucee-extensions\extension-hibernate\tests
set testServices=mysql,mssql

call ant -buildfile "d:\work\script-runner" -DluceeJar="%~1" -Dwebroot="d:\work\lucee7" -Dexecute="test\bootstrap-tests.cfm" -DextensionDir="d:\work\lucee-extensions\extension-hibernate\target" -DuniqueWorkingDir="true"
