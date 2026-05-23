<cfscript>
// Verify properties from BOTH levels of mappedSuperClass ancestry round-trip.
a = entityNew( "Article" );
a.setId( createUUID() );
a.setTitle( "About Mangoes" );
a.setCreatedAt( now() );  // from RootBase (2 levels up)
a.setModifiedBy( "alice" );  // from AuditableBase (1 level up)
entitySave( a );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Article", a.getId() );
if ( isNull( loaded ) )
	throw( message="Article not loaded after save" );
if ( loaded.getTitle() != "About Mangoes" )
	throw( message="title round-trip failed, got [#loaded.getTitle()#]" );
if ( isNull( loaded.getCreatedAt() ) )
	throw( message="createdAt from RootBase (2-level mappedSuperClass) was not persisted" );
if ( loaded.getModifiedBy() != "alice" )
	throw( message="modifiedBy from AuditableBase (1-level mappedSuperClass) was not persisted, got [#loaded.getModifiedBy()#]" );

echo( "ok" );
</cfscript>
