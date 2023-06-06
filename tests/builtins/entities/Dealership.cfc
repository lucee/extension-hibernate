component persistent="true" {

	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="name" type="string";
	property name="address" type="string";
	property name="phone" type="string";
	property name="inventory"
				cfc="Auto"
				fieldtype="one-to-many"
				fkcolumn="dealerID"
				type="array";

	this.name = "Dealership";
}