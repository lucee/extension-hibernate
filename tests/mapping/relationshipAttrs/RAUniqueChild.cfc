component persistent="true" table="RA_UniqueChild" accessors="true" {

	property name="id"     fieldtype="id" ormtype="string";
	property name="name"   ormtype="string";
	// uniquekey groups this FK into a named unique constraint
	// unique=true effectively makes this a one-to-one via many-to-one
	property name="category"
		fieldtype="many-to-one"
		cfc="RACategory"
		fkcolumn="categoryId"
		unique="true"
		uniquekey="uk_category";

}
