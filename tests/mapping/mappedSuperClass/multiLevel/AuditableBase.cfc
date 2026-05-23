// Middle of the chain — mappedSuperClass extending another mappedSuperClass.
component
	mappedSuperClass="true"
	extends         ="RootBase"
	accessors       ="true"
{

	property name="modifiedBy" ormtype="string" length="50";

}
