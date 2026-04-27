<cfscript>
// 7.3 change: collections owned by a read-only entity become read-only.
// arrayAppend then flush should not produce a 3rd DB row regardless of
// whether the platform throws or silently ignores the mutation.

parent = entityLoadByPK( "ROParent", "p1" );
initialCount = arrayLen( parent.getChildren() );
ormGetSession().setReadOnly( parent, true );

newChild = entityNew( "ROChild", { id: "c-new", name: "should-not-persist" } );
newChild.setParent( parent );

try {
	arrayAppend( parent.getChildren(), newChild );
	ormFlush();
} catch ( any e ) {
	// 7.3 throws on read-only collection mutation — acceptable
}

ormClearSession();
reloaded = entityLoadByPK( "ROParent", "p1" );
finalCount = arrayLen( reloaded.getChildren() );
if ( finalCount != initialCount )
	throw( message="Read-only collection add persisted, initial [#initialCount#] now [#finalCount#]" );

echo( "ok" );
</cfscript>
