component persistent="true" table="OB_Playlist" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="tracks"
		fieldtype="one-to-many"
		cfc="Track"
		fkcolumn="playlistId"
		type="array"
		orderby="track_pos ASC";

}
