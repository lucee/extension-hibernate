component accessors="true" persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="name" type="string";
	property
		name      ="courses"
		fieldtype ="many-to-many"
		cfc       ="Course"
		linktable ="student_course"
		fkcolumn  ="studentID"
		inversejoincolumn="courseID"
		type      ="array"
		lazy      ="true";

}
