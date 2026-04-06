<cfscript>
// With dynamicUpdate=true, updating only 'name' should generate SQL
// that only includes the name column, not bio.
// We can't easily verify the SQL shape, but we can verify it works correctly.
id = createUUID();
e = entityNew( "DynEntity", { id: id, name: "Original", bio: "Some bio" } );
entitySave( e );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "DynEntity", id );
loaded.setName( "Updated" );
// don't touch bio
ormFlush();
ormClearSession();

reloaded = entityLoadByPK( "DynEntity", id );
if ( reloaded.getName() != "Updated" )
	throw( message="expected Updated, got #reloaded.getName()#" );
if ( reloaded.getBio() != "Some bio" )
	throw( message="bio should be unchanged: expected 'Some bio', got '#reloaded.getBio()#'" );

echo( "ok" );
</cfscript>
