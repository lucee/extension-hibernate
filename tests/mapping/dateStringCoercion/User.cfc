component persistent="true" table="user_login" accessors="true" {

	property name="id"        fieldtype="id" ormtype="string";
	property name="userName"  ormtype="string" length="50";
	property name="lastLogin" ormtype="date";

}
