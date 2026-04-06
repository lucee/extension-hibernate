component persistent="true" table="FilterEntity" accessors="true" cache="true" {

	property name="id"       fieldtype="id" ormtype="integer" generator="assigned";
	property name="name"     ormtype="string";
	property name="status"   ormtype="string";
	property name="category" ormtype="string";

}
