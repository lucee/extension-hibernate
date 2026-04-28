component persistent="true" table="cascade_child" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// owning side of the FK
	property name="parent" fieldtype="many-to-one" cfc="CascadeParent" fkcolumn="parent_id";
}
