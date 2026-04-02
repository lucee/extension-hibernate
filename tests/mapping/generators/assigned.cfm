<cfscript>
// generator="assigned" — caller must provide the ID
e = entityNew( "AssignedEntity" );
e.setId( "my-custom-id" );
e.setName( "assigned test" );
entitySave( e );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "AssignedEntity", "my-custom-id" );
if ( isNull( loaded ) )
	throw( message="assigned: entity not found after save" );
if ( loaded.getId() != "my-custom-id" )
	throw( message="assigned: expected id [my-custom-id], got [#loaded.getId()#]" );

// assigned generator should NOT auto-generate — saving without ID should fail
try {
	e2 = entityNew( "AssignedEntity" );
	e2.setName( "no id" );
	entitySave( e2 );
	ormFlush();
	throw( message="assigned: should have thrown when saving without ID" );
} catch( any err ) {
	if ( err.message contains "should have thrown" ) rethrow;
	// expected — ids for this class must be manually assigned
}

echo( "ok" );
</cfscript>
