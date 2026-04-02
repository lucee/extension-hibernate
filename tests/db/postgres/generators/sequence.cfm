<cfscript>
// generator="sequence" — uses a named DB sequence (PostgreSQL)
e1 = entityNew( "SequenceEntity" );
e1.setName( "seq first" );
entitySave( e1 );
ormFlush();

id1 = e1.getId();
if ( isNull( id1 ) || id1 == 0 )
	throw( message="sequence: first ID was not generated" );

e2 = entityNew( "SequenceEntity" );
e2.setName( "seq second" );
entitySave( e2 );
ormFlush();

id2 = e2.getId();
if ( id2 <= id1 )
	throw( message="sequence: second ID [#id2#] should be greater than first [#id1#]" );

ormClearSession();
loaded = entityLoadByPK( "SequenceEntity", id1 );
if ( isNull( loaded ) )
	throw( message="sequence: entity not found after save" );

echo( "ok" );
</cfscript>
