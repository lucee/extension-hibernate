component persistent="true" datasource="h2_otherDB" cacheuse="read-write" {

	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="vin" type="string";
	property name="dealer" fieldtype="many-to-one" cfc="Dealership" fkcolumn="dealerId";

}
