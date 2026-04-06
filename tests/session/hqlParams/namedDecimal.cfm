<cfscript>
// named decimal parameter — exercises float/big_decimal type binding
result = ormExecuteQuery( "FROM HqlEntity WHERE price = :price", { price: 19.99 } );
if ( !isArray( result ) || arrayLen( result ) != 1 )
	throw( message="named decimal: expected 1 result, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "bravo" )
	throw( message="named decimal: expected bravo, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
