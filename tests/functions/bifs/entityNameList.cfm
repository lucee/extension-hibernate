<cfscript>
result = entityNameList();
if ( !isSimpleValue( result ) ) throw( message="entityNameList should return string" );
if ( findNoCase( "Auto", result ) == 0 ) throw( message="expected Auto in entity list, got: #result#" );

// with delimiter
result2 = entityNameList( "|" );
if ( findNoCase( "|", result2 ) == 0 && listLen( result2, "|" ) < 1 ) throw( message="delimiter not applied" );

echo( "ok" );
</cfscript>
