// Same table, no filter — for setup and verification
component persistent="true" table="WF_User" accessors="true"
	entityname="AllUser" {

	property name="id"        fieldtype="id" ormtype="string";
	property name="name"      ormtype="string";
	property name="is_active" ormtype="boolean" column="is_active";

}
