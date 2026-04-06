<cfscript>
// one-to-one: Passport shares PK with Citizen
// NOTE: one-to-one in Hibernate means shared PK by default
cid = createUUID();
citizen = entityNew( "Citizen", { id: cid, name: "Alice" } );
entitySave( citizen );

passport = entityNew( "Passport", { id: cid, number: "AU123456" } );
entitySave( passport );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Passport", cid );
if ( !isObject( loaded ) )
	throw( message="passport should load" );
if ( loaded.getNumber() != "AU123456" )
	throw( message="expected AU123456, got #loaded.getNumber()#" );

holder = loaded.getHolder();
if ( !isObject( holder ) )
	throw( message="holder should be loaded (lazy=false)" );
if ( holder.getName() != "Alice" )
	throw( message="expected Alice, got #holder.getName()#" );

echo( "ok" );
</cfscript>
