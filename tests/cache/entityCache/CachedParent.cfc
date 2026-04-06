component persistent="true" table="EC_Parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="items"
		fieldtype="one-to-many"
		cfc="CachedItem"
		fkcolumn="parentId"
		type="array"
		cacheuse="read-only"
		cacheName="itemCache";

}
