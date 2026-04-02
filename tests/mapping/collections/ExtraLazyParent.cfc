component persistent="true" accessors="true" table="COL_ExtraLazy" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

	// bag collection — lazy="extra"
	property
		name="tags"
		fieldtype="collection"
		type="array"
		table="COL_ExtraLazyTags"
		fkcolumn="parentId"
		elementcolumn="tag"
		elementtype="string"
		lazy="extra";

}
