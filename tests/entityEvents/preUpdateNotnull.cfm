<cfscript>
// OOE-12: preUpdate can auto-set a notnull field (password)
theUser = entityNew( "User", {
	id: createUUID(), name: "Julian", username: "jwell", password: "CF4Life"
} );
entitySave( theUser );
ormFlush();
entityReload( theUser );

theUser.setPassword( javaCast( "null", "" ) );
entitySave( theUser );
// preUpdate should detect null password and set it
ormFlush();

ormEvictEntity( "User" );
ormClearSession();

echo( "ok" );
</cfscript>
