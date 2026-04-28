component persistent="true" table="lock_child" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	property name="parent" fieldtype="many-to-one" cfc="LockParent" fkcolumn="parent_id";
}
