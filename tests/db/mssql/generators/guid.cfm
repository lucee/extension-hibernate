<cfscript>
// generator="guid" — DB generates a GUID via NEWID() (MSSQL)
e1 = entityNew( "GuidEntity" );
e1.setName( "guid first" );
entitySave( e1 );
ormFlush();

id1 = e1.getId();
if ( isNull( id1 ) || len( id1 ) == 0 )
	throw( message="guid: ID was not generated" );
// MSSQL NEWID() produces 36-char UUID with hyphens (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
if ( len( id1 ) != 36 )
	throw( message="guid: expected 36-char GUID, got [#id1#] (len=#len( id1 )#)" );

e2 = entityNew( "GuidEntity" );
e2.setName( "guid second" );
entitySave( e2 );
ormFlush();

if ( e2.getId() == id1 )
	throw( message="guid: two entities got the same GUID" );

ormClearSession();
loaded = entityLoadByPK( "GuidEntity", id1 );
if ( isNull( loaded ) )
	throw( message="guid: entity not found after save" );

echo( "ok" );
</cfscript>
