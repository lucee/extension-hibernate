component persistent="true" table="subselect_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// fetch="subselect" — Hibernate emits one IN-subselect to load all parents'
	// children when any one parent's collection is touched. Currently rejected by
	// HBMCreator's fetch validator (allows only "join,select"); see fetchSubselect.cfc.
	property name="children"
		fieldtype="one-to-many"
		cfc="SubselectChild"
		fkcolumn="parent_id"
		fetch="subselect"
		lazy="true";
}
