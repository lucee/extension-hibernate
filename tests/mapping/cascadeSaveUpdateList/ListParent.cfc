component persistent="true" table="list_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// Multi-token cascade — common cborm/ColdBox pattern. Locks the contract for
	// the comma-separated list form so the H7 translator preserves it.
	property name="children"
		fieldtype="one-to-many"
		cfc="ListChild"
		fkcolumn="parent_id"
		cascade="save-update,delete-orphan"
		inverse="false";
}
