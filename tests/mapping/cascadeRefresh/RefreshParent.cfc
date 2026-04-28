component persistent="true" table="refresh_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// cascade="refresh" — propagate session.refresh() to children. Should work on H7.
	property name="children"
		fieldtype="one-to-many"
		cfc="RefreshChild"
		fkcolumn="parent_id"
		cascade="refresh"
		inverse="false";
}
