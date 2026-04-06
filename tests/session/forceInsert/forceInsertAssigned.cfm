<cfscript>
// forceInsert with generator=assigned and pre-set ID — verify ID survives persist
entity = entityNew( "AssignedEntity" );
entity.setId( "my-custom-id" );
entity.setName( "test" );
entitySave( entity, true );
ormFlush();

if ( entity.getId() != "my-custom-id" )
	throw( message="forceInsert assigned: expected my-custom-id, got [#entity.getId()#]" );

// verify it's in the DB
ormClearSession();
loaded = entityLoadByPK( "AssignedEntity", "my-custom-id" );
if ( isNull( loaded ) )
	throw( message="forceInsert assigned: entity not found in DB after flush" );
echo( "ok" );
</cfscript>
