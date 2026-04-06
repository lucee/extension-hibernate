<cfscript>
// constrained="true" means the FK is enforced — Passport must have a matching Citizen
cid = createUUID();
citizen = entityNew( "Citizen", { id: cid, name: "Bob" } );
entitySave( citizen );

passport = entityNew( "ConstrainedPassport", { id: cid, number: "NZ987654" } );
entitySave( passport );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "ConstrainedPassport", cid );
if ( !isObject( loaded ) )
	throw( message="constrained passport should load" );
if ( loaded.getHolder().getName() != "Bob" )
	throw( message="expected Bob, got #loaded.getHolder().getName()#" );

echo( "ok" );
</cfscript>
