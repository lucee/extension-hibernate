component accessors="true" persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="title" type="string";
	property
		name      ="students"
		fieldtype ="many-to-many"
		cfc       ="Student"
		linktable ="student_course"
		fkcolumn  ="courseID"
		inversejoincolumn="studentID"
		type      ="array"
		lazy      ="true"
		inverse   ="true";

}
