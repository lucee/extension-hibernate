component
	persistent="true"
	extends   ="BaseEntity"
	accessors ="true"
	table     ="mappedsuper_user"
{

	property name="id"       fieldtype="id" ormtype="string";
	property name="userName" ormtype="string" length="50";

}
