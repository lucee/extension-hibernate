component persistent="true" table="RO_Child" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="parent"
		fieldtype="many-to-one"
		cfc="ROParent"
		fkcolumn="parentId";

}
