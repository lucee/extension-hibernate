component persistent="true" table="BS_Book" accessors="true" {

	property name="id"    fieldtype="id" ormtype="string";
	property name="title" ormtype="string";
	property name="publisher"
		fieldtype="many-to-one"
		cfc="Publisher"
		fkcolumn="publisherId";

}
