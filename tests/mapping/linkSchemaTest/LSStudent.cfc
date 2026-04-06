component persistent="true" table="LS_Student" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="courses"
		fieldtype="many-to-many"
		cfc="LSCourse"
		linktable="ls_enrollment"
		linkschema="orm_link_schema_test"
		fkcolumn="studentId"
		inversejoincolumn="courseId"
		type="array"
		lazy="true";

}
