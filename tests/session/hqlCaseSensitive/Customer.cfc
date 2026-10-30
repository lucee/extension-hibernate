component persistent="true" table="HqlCaseCustomer" accessors="true" {

	property name="id"           fieldtype="id" ormtype="integer" generator="assigned";
	property name="UserName"     ormtype="string";
	property name="EmailAddress" ormtype="string";
	property name="BirthDate"    ormtype="date";

}
