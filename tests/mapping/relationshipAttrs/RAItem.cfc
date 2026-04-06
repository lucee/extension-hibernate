component persistent="true" table="RA_Item" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	// notnull=true on FK — category is required
	// insert=true, update=false — FK set on insert, can't change category after
	property name="category"
		fieldtype="many-to-one"
		cfc="RACategory"
		fkcolumn="categoryId"
		notnull="true"
		insert="true"
		update="false";

}
