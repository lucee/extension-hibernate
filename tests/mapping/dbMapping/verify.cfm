<cfscript>
// With useDBForMapping=true, ORM should read schema from DB
// Verify basic operation works — save and load
widget = entityNew( "Widget", { id: createUUID(), name: "Sprocket" } );
entitySave( widget );
ormFlush();

ormClearSession();
loaded = entityLoadByPK( "Widget", widget.getId() );
if ( isNull( loaded ) ) throw( message="Widget not loaded" );
if ( loaded.getName() != "Sprocket" ) throw( message="expected Sprocket, got #loaded.getName()#" );

echo( "ok" );
</cfscript>
