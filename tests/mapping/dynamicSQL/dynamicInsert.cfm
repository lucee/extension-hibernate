<cfscript>
id = createUUID();
e = entityNew( "DynEntity", { id: id, name: "Test" } );
// bio is null — with dynamicInsert, INSERT should omit bio column
entitySave( e );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "DynEntity", id );
if ( loaded.getName() != "Test" )
	throw( message="expected Test, got #loaded.getName()#" );

echo( "ok" );
</cfscript>
