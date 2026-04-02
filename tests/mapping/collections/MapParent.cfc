component persistent="true" accessors="true" table="COL_MapParent" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

	// map collection — default lazy (no lazy attr)
	property
		name="metadata"
		fieldtype="collection"
		type="struct"
		table="COL_MapMeta"
		fkcolumn="parentId"
		structKeyColumn="metaKey"
		structKeyType="string"
		elementcolumn="metaValue"
		elementtype="string";

}
