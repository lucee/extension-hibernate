component persistent="true" accessors="true" table="COL_ArrayParent" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

	// bag collection — default lazy (no lazy attr)
	property
		name="tags"
		fieldtype="collection"
		type="array"
		table="COL_ArrayTags"
		fkcolumn="parentId"
		elementcolumn="tag"
		elementtype="string";

}
