<cfscript>
// generator="native" — delegates to identity/sequence/hilo depending on DB dialect
e1 = entityNew( "NativeEntity" );
e1.setName( "native first" );
entitySave( e1 );
ormFlush();

id1 = e1.getId();
if ( isNull( id1 ) || id1 == 0 )
	throw( message="native: first ID was not generated" );

e2 = entityNew( "NativeEntity" );
e2.setName( "native second" );
entitySave( e2 );
ormFlush();

id2 = e2.getId();
if ( id2 <= id1 )
	throw( message="native: second ID [#id2#] should be greater than first [#id1#]" );

ormClearSession();
loaded = entityLoadByPK( "NativeEntity", id1 );
if ( isNull( loaded ) )
	throw( message="native: entity not found after save" );

echo( "ok" );
</cfscript>
