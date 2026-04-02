component accessors="true" persistent="true" table="gen_uuid" {
	property name="id"   fieldtype="id" ormtype="string" length="32" generator="uuid";
	property name="name" ormtype="string";
}
