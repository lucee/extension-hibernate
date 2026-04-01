<cfscript>
ormClearSession();
echo( serializeJSON( application.ormEventLog ) );
</cfscript>
