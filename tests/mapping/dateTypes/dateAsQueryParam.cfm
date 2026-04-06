<cfscript>
// use loaded date as HQL query parameter — verify the loaded type can be round-tripped
original = createDate( 2025, 6, 15 );
entity = entityNew( "DateEntity" );
entity.setId( createUUID() );
entity.setDateValue( original );
entitySave( entity );
ormFlush();
ormClearSession();

// reload
loaded = entityLoadByPK( "DateEntity", entity.getId() );
// use loaded date value as a query param
result = ormExecuteQuery( "FROM DateEntity WHERE dateValue = :d", { d: loaded.getDateValue() } );
if ( arrayLen( result ) < 1 )
	throw( message="dateAsQueryParam: expected at least 1 result, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
