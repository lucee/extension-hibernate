// Entity with a unique non-PK column that can be referenced by mappedby
component persistent="true" table="RA_Lookup" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="code" ormtype="string" unique="true";
	property name="label" ormtype="string";

}
