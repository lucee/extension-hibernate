component persistent="true" table="LP_Customer" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="address"
		fieldtype="many-to-one"
		cfc="Address"
		fkcolumn="addressId"
		lazy="proxy";

}
