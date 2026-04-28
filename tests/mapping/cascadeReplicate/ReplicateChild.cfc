component persistent="true" table="replicate_child" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="assigned";
	property name="name" ormtype="string" length="50";

	property name="parent" fieldtype="many-to-one" cfc="ReplicateParent" fkcolumn="parent_id";
}
