component accessors="true" persistent="true" table="bad_type" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		generator="assigned";

	// "garbage" is not a valid ormtype — should error, not silently default to string
	property name="score" ormtype="garbage" type="numeric";
}
