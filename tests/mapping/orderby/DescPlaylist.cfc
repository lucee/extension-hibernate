component persistent="true" table="OB_DescPlaylist" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="tracks"
		fieldtype="one-to-many"
		cfc="Track"
		fkcolumn="descPlaylistId"
		type="array"
		orderby="track_pos DESC";

}
