// Real entity at the root of a TPH hierarchy, but inherits from a mappedSuperClass.
// Exercises both the mappedSuperClass parent-lookup path AND the real-entity
// subclass machinery (Car below).
component
	persistent         ="true"
	extends            ="AuditedBase"
	accessors          ="true"
	table              ="msuper_mixed_vehicle"
	discriminatorColumn="vehicle_type"
	discriminatorValue ="vehicle"
{

	property name="id"     fieldtype="id" ormtype="string";
	property name="wheels" ormtype="integer";

}
