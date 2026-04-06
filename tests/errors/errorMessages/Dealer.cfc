component accessors="true" persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";
	property name="name" type="string";
	property
		name     ="topAuto"
		fieldtype="many-to-one"
		cfc      ="Auto"
		fkcolumn ="topAutoId";
		// no cascade — saving Dealer won't auto-save the Auto

}
