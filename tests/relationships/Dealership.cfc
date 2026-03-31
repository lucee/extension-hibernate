component accessors="true" persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="name"    type="string";
	property name="address" type="string";
	property
		name        ="inventory"
		fieldtype   ="one-to-many"
		cfc         ="Auto"
		fkcolumn    ="dealerID"
		type        ="array"
		cascade     ="all-delete-orphan"
		inverse     ="true";

}
