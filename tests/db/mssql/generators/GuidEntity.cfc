component accessors="true" persistent="true" table="gen_guid" {
	property name="id"   fieldtype="id" ormtype="string" length="36" generator="guid";
	property name="name" ormtype="string";
}
