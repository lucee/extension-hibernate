<cfscript>
// Verify session.setReadOnly() / session.isReadOnly() round-trip.

parent = entityLoadByPK( "ROParent", "p1" );
// `session` is a CFML scope name, can't be used as a variable
hibSession = ormGetSession();

if ( hibSession.isReadOnly( parent ) )
	throw( message="Entity unexpectedly read-only at load" );

hibSession.setReadOnly( parent, true );
if ( !hibSession.isReadOnly( parent ) )
	throw( message="setReadOnly( entity, true ) did not flip isReadOnly()" );

hibSession.setReadOnly( parent, false );
if ( hibSession.isReadOnly( parent ) )
	throw( message="setReadOnly( entity, false ) did not flip isReadOnly()" );

echo( "ok" );
</cfscript>
