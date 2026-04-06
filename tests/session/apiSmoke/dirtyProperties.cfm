<cfscript>
// Test dirty detection via Hibernate ormSess API
id = createUUID();
entity = entityNew( "SmokeEntity", { id: id, name: "Original" } );
entitySave( entity );
ormFlush();

ormSess = ORMGetSession();

// after flush, ormSess should not be dirty
if ( ormSess.isDirty() )
	throw( message="ormSess should NOT be dirty after flush" );

// modify entity without flushing
entity.setName( "Modified" );

// now ormSess should be dirty
if ( !ormSess.isDirty() )
	throw( message="ormSess SHOULD be dirty after modification" );

// getIdentifier should return the PK
identifier = ormSess.getIdentifier( entity );
if ( identifier != id )
	throw( message="expected identifier #id#, got #identifier#" );

// flush and verify clean again
ormFlush();
if ( ormSess.isDirty() )
	throw( message="ormSess should NOT be dirty after second flush" );

echo( "ok" );
</cfscript>
