component persistent="true" accessors="true" table="COL_EagerMap" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";

	// map collection — lazy="false" (eager)
	property
		name="metadata"
		fieldtype="collection"
		type="struct"
		table="COL_EagerMapMeta"
		fkcolumn="parentId"
		structKeyColumn="metaKey"
		structKeyType="string"
		elementcolumn="metaValue"
		elementtype="string"
		lazy="false";

}
