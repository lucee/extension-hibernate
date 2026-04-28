component persistent="true" table="cascade_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// one-to-many with cascade="save-update" — H5 contract: entitySave(parent) with
	// transient children attached must cascade-persist the children. H7 dropped the
	// cascade style, so this is the canary test for the gap.
	property name="children"
		fieldtype="one-to-many"
		cfc="CascadeChild"
		fkcolumn="parent_id"
		cascade="save-update"
		inverse="false";
}
