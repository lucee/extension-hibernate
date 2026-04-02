component accessors="true" persistent="true" table="parents" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		generator="assigned";

	property name="name" type="string";

	property
		name          ="children"
		fieldtype     ="one-to-many"
		cfc           ="Child"
		fkcolumn      ="parentId"
		collectionType="badvalue";
}
