// Real subclass of a real entity that itself extends a mappedSuperClass.
component
	persistent        ="true"
	extends           ="Vehicle"
	accessors         ="true"
	discriminatorValue="car"
{

	property name="doors" ormtype="integer";

}
