component persistent="true" table="UC_Email" accessors="true" {

	property name="id"      fieldtype="id" ormtype="string";
	property name="address" ormtype="string" unique="true";

}
