component persistent="true" table="F_OrderItem" accessors="true" {

	property name="id"       fieldtype="id" ormtype="string";
	property name="quantity" ormtype="integer";
	property name="price"    ormtype="big_decimal";
	// computed property — not stored in DB
	property name="total" formula="quantity * price" type="numeric";

}
