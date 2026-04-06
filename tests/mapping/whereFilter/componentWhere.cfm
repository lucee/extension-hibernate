<cfscript>
// Insert 2 users: one active, one inactive via direct SQL
queryExecute( "INSERT INTO WF_User ( id, name, is_active ) VALUES ( :id, :name, :active )",
	{ id: createUUID(), name: "Active Alice", active: true } );
queryExecute( "INSERT INTO WF_User ( id, name, is_active ) VALUES ( :id, :name, :active )",
	{ id: createUUID(), name: "Inactive Bob", active: false } );

ormClearSession();

// ActiveUser entity has where="is_active = true"
active = entityLoad( "ActiveUser" );
if ( arrayLen( active ) != 1 )
	throw( message="expected 1 active user, got #arrayLen( active )#" );
if ( active[ 1 ].getName() != "Active Alice" )
	throw( message="expected Active Alice, got #active[ 1 ].getName()#" );

// Verify both rows exist via SQL
all = queryExecute( "SELECT count(*) as cnt FROM WF_User" );
if ( all.cnt != 2 )
	throw( message="expected 2 total users in DB, got #all.cnt#" );

echo( "ok" );
</cfscript>
