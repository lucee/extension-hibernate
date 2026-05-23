// Real entity at the bottom — inherits createdAt (from RootBase) and modifiedBy (from AuditableBase).
component
	persistent="true"
	extends   ="AuditableBase"
	accessors ="true"
	table     ="msuper_article"
{

	property name="id"    fieldtype="id" ormtype="string";
	property name="title" ormtype="string" length="200";

}
