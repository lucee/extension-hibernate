component persistent="true" table="CM_Contact" accessors="true" {

	property name="id"        fieldtype="id" ormtype="string";
	property name="firstName" ormtype="string" column="first_name";
	property name="lastName"  ormtype="string" column="last_name";
	property name="emailAddr" ormtype="string" column="email_address";

}
