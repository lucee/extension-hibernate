component accessors="true" persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="model" type="string";
	property
		name     ="garage"
		fieldtype="many-to-one"
		cfc      ="dotted.Garage"
		fkcolumn ="garageID";

}
