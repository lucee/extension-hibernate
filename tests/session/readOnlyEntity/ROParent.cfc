component persistent="true" table="RO_Parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="children"
		fieldtype="one-to-many"
		cfc="ROChild"
		fkcolumn="parentId"
		type="array"
		cascade="all";

}
