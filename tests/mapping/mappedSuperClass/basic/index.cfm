<cfscript>
// Exercise the entity so SF init definitely runs and the mappedSuperClass
// inheritance path is actually traversed.
seed = entityNew( "User" );
seed.setId( createUUID() );
seed.setUserName( "Alice" );
seed.setCreatedAt( now() );
entitySave( seed );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "User", seed.getId() );
if ( isNull( loaded ) )
	throw( message="User not loaded after save" );
if ( loaded.getUserName() != "Alice" )
	throw( message="expected Alice, got [#loaded.getUserName()#]" );
if ( isNull( loaded.getCreatedAt() ) )
	throw( message="mappedSuperClass property createdAt was not persisted" );

echo( "ok" );
</cfscript>
