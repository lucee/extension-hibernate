component accessors="true" persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="name"     type="string";
	property name="age"      ormtype="integer";
	property name="active"   ormtype="boolean" default="true";

}
