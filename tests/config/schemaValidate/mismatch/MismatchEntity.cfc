// Maps to a table that does NOT exist in the DB — validate mode should reject this
component persistent="true" table="SV_DOES_NOT_EXIST" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

}
