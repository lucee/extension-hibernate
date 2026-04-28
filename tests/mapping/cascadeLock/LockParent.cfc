component persistent="true" table="lock_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// cascade="lock" — propagate session.lock() calls to children. Should work on H7.
	property name="children"
		fieldtype="one-to-many"
		cfc="LockChild"
		fkcolumn="parent_id"
		cascade="lock"
		inverse="false";
}
