component persistent="true" accessors="true" {

	property name="id" fieldtype="id" ormtype="string";
	property name="child"
		fieldtype="many-to-one"
		cfc="Child"
		fkcolumn="childId"
		fetch="bogus";

}
