<cfscript>
// session.setReadOnly( entity, true ) — scalar mutations must not persist.
// Whether Hibernate throws or silently ignores is platform-defined; the
// contract we assert is "read-only entity changes never reach the DB".

parent = entityLoadByPK( "ROParent", "p1" );
ormGetSession().setReadOnly( parent, true );

try {
	parent.setName( "mutated" );
	ormFlush();
} catch ( any e ) {
	// 7.3 may start throwing — acceptable, the persist outcome is what matters
}

ormClearSession();
reloaded = entityLoadByPK( "ROParent", "p1" );
if ( reloaded.getName() != "parent-one" )
	throw( message="Read-only scalar mutation persisted, expected [parent-one] got [#reloaded.getName()#]" );

echo( "ok" );
</cfscript>
