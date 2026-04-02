<cfscript>
// generator="increment" — Hibernate reads max(id) + 1
e1 = entityNew( "IncrementEntity" );
e1.setName( "first" );
entitySave( e1 );
ormFlush();

id1 = e1.getId();
if ( isNull( id1 ) || id1 == 0 )
	throw( message="increment: first ID was not generated" );

e2 = entityNew( "IncrementEntity" );
e2.setName( "second" );
entitySave( e2 );
ormFlush();

id2 = e2.getId();
if ( id2 <= id1 )
	throw( message="increment: second ID [#id2#] should be greater than first [#id1#]" );

ormClearSession();
loaded = entityLoadByPK( "IncrementEntity", id1 );
if ( isNull( loaded ) )
	throw( message="increment: entity not found after save" );

echo( "ok" );
</cfscript>
