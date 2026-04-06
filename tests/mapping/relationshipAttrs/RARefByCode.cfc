// many-to-one with mappedby — FK references the 'code' property (unique column)
// instead of the PK. This is CFML ORM's actual use of mappedby.
component persistent="true" table="RA_RefByCode" accessors="true" {

	property name="id"     fieldtype="id" ormtype="string";
	property name="name"   ormtype="string";
	property name="lookup"
		fieldtype="many-to-one"
		cfc="RALookup"
		fkcolumn="lookupCode"
		mappedby="code";

}
