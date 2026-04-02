component persistent="true" accessors="true" table="COL_EagerArray" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

	// bag collection — lazy="false" (eager)
	property
		name="tags"
		fieldtype="collection"
		type="array"
		table="COL_EagerArrayTags"
		fkcolumn="parentId"
		elementcolumn="tag"
		elementtype="string"
		lazy="false";

}
