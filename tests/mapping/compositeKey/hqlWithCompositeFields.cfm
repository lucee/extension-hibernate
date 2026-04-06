<cfscript>
// HQL with composite key fields
result = ormExecuteQuery(
	"FROM CompositeEntity WHERE keyPart1 = :k1 AND keyPart2 = :k2",
	{ k1: "a", k2: 1 }
);
if ( arrayLen( result ) != 1 )
	throw( message="hqlComposite: expected 1, got #arrayLen( result )#" );
if ( result[ 1 ].getLabel() != "first" )
	throw( message="hqlComposite: expected first, got [#result[ 1 ].getLabel()#]" );
echo( "ok" );
</cfscript>
