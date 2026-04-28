component persistent="true" table="refresh_child" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	property name="parent" fieldtype="many-to-one" cfc="RefreshParent" fkcolumn="parent_id";
}
