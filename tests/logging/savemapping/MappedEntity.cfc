component persistent="true" table="MappedEntity" accessors="true" {

	property name="id"    type="string" fieldtype="id" ormtype="string";
	property name="title" type="string";
	property name="price" type="numeric" ormtype="big_decimal" precision="12" scale="4";

}
