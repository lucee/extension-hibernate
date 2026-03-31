<cfscript>
result = entityNameArray();
if ( !isArray( result ) ) throw( message="entityNameArray should return array" );
if ( arrayFindNoCase( result, "Auto" ) == 0 ) throw( message="expected Auto in entity names, got: #arrayToList( result )#" );

echo( "ok" );
</cfscript>
