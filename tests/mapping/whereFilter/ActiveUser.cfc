// Component-level where filter — only loads active users
component persistent="true" table="WF_User" accessors="true"
	entityname="ActiveUser" where="is_active = true" {

	property name="id"        fieldtype="id" ormtype="string";
	property name="name"      ormtype="string";
	property name="is_active" ormtype="boolean" column="is_active";

}
