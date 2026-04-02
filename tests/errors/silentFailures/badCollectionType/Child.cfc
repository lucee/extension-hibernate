component accessors="true" persistent="true" table="children" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		generator="assigned";

	property name="name" type="string";

	property
		name     ="parentId"
		type     ="string"
		column   ="parentId";
}
