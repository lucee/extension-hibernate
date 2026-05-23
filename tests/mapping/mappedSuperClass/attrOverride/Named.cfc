// mappedSuperClass with a default column name and short length.
// Child overrides both via redeclaration.
component
	mappedSuperClass="true"
	accessors       ="true"
{

	property
		name   ="title"
		ormtype="string"
		length ="50"
		column ="default_title";

}
