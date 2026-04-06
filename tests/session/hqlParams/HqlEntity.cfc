component persistent="true" table="HqlEntity" accessors="true" {

	property name="id"      fieldtype="id" ormtype="integer" generator="assigned";
	property name="name"    ormtype="string";
	property name="price"   ormtype="big_decimal";
	property name="active"  ormtype="boolean";
	property name="created" ormtype="date";

}
