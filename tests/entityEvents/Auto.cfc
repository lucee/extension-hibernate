component accessors="true" persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="make"  type="string";
	property name="model" type="string";
	property
		name   ="inserted"
		type   ="boolean"
		default="false";
	property
		name   ="updated"
		type   ="boolean"
		default="false";

	function preInsert() {
		setInserted( true );
	}

	function preUpdate() {
		setUpdated( true );
	}

}
