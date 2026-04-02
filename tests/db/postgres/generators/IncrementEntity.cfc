component accessors="true" persistent="true" table="gen_increment" {
	property name="id"   fieldtype="id" ormtype="long" generator="increment";
	property name="name" ormtype="string";
}
