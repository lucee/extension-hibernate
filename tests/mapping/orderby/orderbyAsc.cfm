<cfscript>
pid = createUUID();
pl = entityNew( "Playlist", { id: pid, name: "My Mix" } );
entitySave( pl );
ormFlush();

// insert tracks in non-sequential order
for ( pos in [ 3, 1, 2 ] ) {
	queryExecute(
		"INSERT INTO OB_Track ( id, title, track_pos, playlistId ) VALUES ( :id, :title, :pos, :pid )",
		{ id: createUUID(), title: "Track #pos#", pos: pos, pid: pid }
	);
}
ormClearSession();

loaded = entityLoadByPK( "Playlist", pid );
tracks = loaded.getTracks();
if ( arrayLen( tracks ) != 3 )
	throw( message="expected 3 tracks, got #arrayLen( tracks )#" );

// verify order: track_pos 1, 2, 3
if ( tracks[ 1 ].getTrackPos() != 1 || tracks[ 2 ].getTrackPos() != 2 || tracks[ 3 ].getTrackPos() != 3 )
	throw( message="tracks not in order. got #tracks[ 1 ].getTrackPos()#, #tracks[ 2 ].getTrackPos()#, #tracks[ 3 ].getTrackPos()#" );

echo( "ok" );
</cfscript>
