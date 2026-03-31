<cfscript>
// OOE-9: preInsert persists date value state changes
theUser = entityNew( "User", {
	id: createUUID(), name: "Julian", username: "jwell", password: "CF4Life"
} );
if ( !isNull( theUser.getDateCreated() ) ) throw( message="dateCreated should be null before flush" );

entitySave( theUser );
ormFlush();

if ( isNull( theUser.getDateCreated() ) ) throw( message="preInsert should have set dateCreated" );

entityReload( theUser );
if ( isNull( theUser.getDateCreated() ) ) throw( message="persisted dateCreated should not be null" );

echo( "ok" );
</cfscript>
