component persistent="true" table="WF_Department" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="activeStaff"
		fieldtype="one-to-many"
		cfc="Staff"
		fkcolumn="deptId"
		type="array"
		where="is_active = true";

}
