component persistent="true" table="RA_Category" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	// readonly=true — collection is read-only, never modified via ORM
	property name="items"
		fieldtype="one-to-many"
		cfc="RAItem"
		fkcolumn="categoryId"
		type="array"
		readonly="true";

}
