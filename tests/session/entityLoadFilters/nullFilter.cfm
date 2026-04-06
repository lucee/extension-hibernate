<cfscript>
// null filter value — hits Restrictions.isNull() path
// first insert a row with null status
entity = entityNew( "FilterEntity" );
entity.setId( 99 );
entity.setName( "nulltest" );
entity.setCategory( "books" );
// status left null
entitySave( entity );
ormFlush();
ormClearSession();

result = entityLoad( "FilterEntity", { status: javacast( "null", "" ) } );
if ( arrayLen( result ) != 1 )
	throw( message="null filter: expected 1, got #arrayLen( result )#" );
if ( result[ 1 ].getName() != "nulltest" )
	throw( message="null filter: expected nulltest, got #result[ 1 ].getName()#" );
echo( "ok" );
</cfscript>
