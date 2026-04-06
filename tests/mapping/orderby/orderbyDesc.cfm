<cfscript>
// orderby="track_pos DESC" attribute on the one-to-many relationship
pid = createUUID();
pl = entityNew( "DescPlaylist", { id: pid, name: "Reverse Mix" } );
entitySave( pl );
ormFlush();

for ( pos in [ 1, 3, 2 ] ) {
	queryExecute(
		"INSERT INTO OB_Track ( id, title, track_pos, descPlaylistId ) VALUES ( :id, :title, :pos, :pid )",
		{ id: createUUID(), title: "Track #pos#", pos: pos, pid: pid }
	);
}
ormClearSession();

loaded = entityLoadByPK( "DescPlaylist", pid );
tracks = loaded.getTracks();
if ( arrayLen( tracks ) != 3 )
	throw( message="expected 3 tracks, got #arrayLen( tracks )#" );

// verify order: track_pos 3, 2, 1 (DESC)
if ( tracks[ 1 ].getTrackPos() != 3 || tracks[ 2 ].getTrackPos() != 2 || tracks[ 3 ].getTrackPos() != 1 )
	throw( message="tracks not in DESC order. got #tracks[ 1 ].getTrackPos()#, #tracks[ 2 ].getTrackPos()#, #tracks[ 3 ].getTrackPos()#" );

echo( "ok" );
</cfscript>
