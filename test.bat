SET "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-11.0.29.7-hotspot"
call mvn package
if %errorlevel% neq 0 exit /b %errorlevel%
set testLabels=orm
set testFilter=
set testAdditional=d:\work\lucee-extensions\extension-hibernate\tests
set testServices=mysql,mssql

call ant -buildfile "d:\work\script-runner" -DluceeVersion="7.0/snapshot/light" -Dwebroot="d:\work\lucee7" -Dexecute="test\bootstrap-tests.cfm" -DextensionDir="d:\work\lucee-extensions\extension-hibernate\target"