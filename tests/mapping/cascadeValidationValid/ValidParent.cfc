component persistent="true" table="cv_valid_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// Mix the save-update bridge token (rewritten to persist,merge for H7),
	// a native H7 token (delete-orphan implies orphan removal on collections),
	// and another native token (merge). All must pass validation and build.
	property name="children"
		fieldtype="one-to-many"
		cfc="ValidChild"
		fkcolumn="parent_id"
		cascade="save-update,delete-orphan,merge"
		inverse="false";
}
