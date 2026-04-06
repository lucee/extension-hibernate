component persistent="true" table="WF_Staff" accessors="true" {

	property name="id"        fieldtype="id" ormtype="string";
	property name="name"      ormtype="string";
	property name="is_active" ormtype="boolean" column="is_active";

}
