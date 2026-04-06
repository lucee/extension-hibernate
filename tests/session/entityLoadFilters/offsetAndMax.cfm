<cfscript>
// pagination offset + maxresults
all = entityLoad( "FilterEntity", { status: "active" }, "name ASC" );
result = entityLoad( "FilterEntity", { status: "active" }, "name ASC", { offset: 1, maxresults: 2 } );
if ( arrayLen( result ) != 2 )
	throw( message="offset+max: expected 2, got #arrayLen( result )#" );
// with offset 1, should skip first and get second+third
if ( result[ 1 ].getName() != all[ 2 ].getName() )
	throw( message="offset+max: first result should be #all[ 2 ].getName()#, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
