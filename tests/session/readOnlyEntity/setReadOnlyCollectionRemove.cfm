<cfscript>
// 7.3 change: removing from a collection on a read-only entity must not persist.

parent = entityLoadByPK( "ROParent", "p1" );
initialCount = arrayLen( parent.getChildren() );
ormGetSession().setReadOnly( parent, true );

try {
	arrayDeleteAt( parent.getChildren(), 1 );
	ormFlush();
} catch ( any e ) {
	// 7.3 may throw — acceptable, persistence outcome is what we lock down
}

ormClearSession();
reloaded = entityLoadByPK( "ROParent", "p1" );
finalCount = arrayLen( reloaded.getChildren() );
if ( finalCount != initialCount )
	throw( message="Read-only collection remove persisted, initial [#initialCount#] now [#finalCount#]" );

echo( "ok" );
</cfscript>
