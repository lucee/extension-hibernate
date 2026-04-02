<cfscript>
// generator="identity" — DB auto-increment column
e1 = entityNew( "IdentityEntity" );
e1.setName( "identity first" );
entitySave( e1 );
ormFlush();

id1 = e1.getId();
if ( isNull( id1 ) || id1 == 0 )
	throw( message="identity: first ID was not generated" );

e2 = entityNew( "IdentityEntity" );
e2.setName( "identity second" );
entitySave( e2 );
ormFlush();

id2 = e2.getId();
if ( id2 <= id1 )
	throw( message="identity: second ID [#id2#] should be greater than first [#id1#]" );

ormClearSession();
loaded = entityLoadByPK( "IdentityEntity", id1 );
if ( isNull( loaded ) )
	throw( message="identity: entity not found after save" );

echo( "ok" );
</cfscript>
