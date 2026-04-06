component persistent="true" table="OB_Track" accessors="true" {

	property name="id"       fieldtype="id" ormtype="string";
	property name="title"    ormtype="string";
	property name="trackPos" ormtype="integer" column="track_pos";

}
