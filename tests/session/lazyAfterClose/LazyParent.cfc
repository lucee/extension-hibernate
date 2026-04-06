component persistent="true" table="LAC_Parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="children"
		fieldtype="one-to-many"
		cfc="LazyChild"
		fkcolumn="parentId"
		type="array"
		lazy="true";

}
