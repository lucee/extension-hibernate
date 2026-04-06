<cfscript>
tid = createUUID();
team = entityNew( "Team", { id: tid, name: "Lucee FC" } );
entitySave( team );

p1 = entityNew( "Player", { id: createUUID(), name: "Alice", team: team } );
p2 = entityNew( "Player", { id: createUUID(), name: "Bob", team: team } );
entitySave( p1 );
entitySave( p2 );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Team", tid );
players = loaded.getPlayers();
if ( !isArray( players ) || arrayLen( players ) != 2 )
	throw( message="expected 2 players, got #isArray( players ) ? arrayLen( players ) : 'non-array'#" );

echo( "ok" );
</cfscript>
