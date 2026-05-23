// Child entity redeclares `title` with different `column` + `length`.
// JPA's @AttributeOverride equivalent in CFML — same property name, new attrs.
component
	persistent="true"
	extends   ="Named"
	accessors ="true"
	table     ="msuper_customer"
{

	property name="id" fieldtype="id" ormtype="string";
	property
		name   ="title"
		ormtype="string"
		length ="200"
		column ="customer_title";

}
