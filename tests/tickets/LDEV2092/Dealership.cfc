component persistent="true" datasource="h2_otherDB" cacheuse="read-write" {

	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="name" type="string";
	property name="inventory" fieldtype="one-to-many" cfc="Vehicle" fkcolumn="dealerId";

}
