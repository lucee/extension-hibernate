<cfscript>
// OOE-9: preUpdate persists date value state changes
theUser = entityNew( "User", {
	id: createUUID(), name: "Julian", username: "jwell", password: "CF4Life"
} );
entitySave( theUser );
ormFlush();
entityReload( theUser );
if ( !isNull( theUser.getDateUpdated() ) ) throw( message="dateUpdated should be null before update" );

theUser.setName( "Julian Halliwell" );
entitySave( theUser );
ormFlush();
entityReload( theUser );

if ( isNull( theUser.getDateUpdated() ) ) throw( message="preUpdate should have set dateUpdated" );

echo( "ok" );
</cfscript>
