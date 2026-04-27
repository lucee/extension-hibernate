component persistent="true" table="MultiEntity" accessors="true" {

	property name="id"     fieldtype="id" ormtype="integer" generator="assigned";
	property name="name"   ormtype="string";
	property name="status" ormtype="string";

}
