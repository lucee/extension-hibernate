<cfscript>
id = createUUID();
e = entityNew( "SBUEntity", { id: id, name: "Original" } );
entitySave( e );
ormFlush();
ormClearSession();

// reload, set same value, flush — should not error
loaded = entityLoadByPK( "SBUEntity", id );
loaded.setName( "Original" );
ormFlush();
ormClearSession();

reloaded = entityLoadByPK( "SBUEntity", id );
if ( reloaded.getName() != "Original" )
	throw( message="expected Original, got #reloaded.getName()#" );

echo( "ok" );
</cfscript>
