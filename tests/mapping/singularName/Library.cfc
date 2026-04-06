component persistent="true" table="SN_Library" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="books"
		singularName="book"
		fieldtype="one-to-many"
		cfc="LibBook"
		fkcolumn="libraryId"
		type="array"
		cascade="all";

}
