component persistent="true" table="replicate_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="assigned";
	property name="name" ormtype="string" length="50";

	// cascade="replicate" — propagate session.replicate() to children. Should work on H7.
	property name="children"
		fieldtype="one-to-many"
		cfc="ReplicateChild"
		fkcolumn="parent_id"
		cascade="replicate"
		inverse="false";
}
