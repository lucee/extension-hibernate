// JPA pattern: mappedSuperClass declares the @Id; children inherit it.
component
	mappedSuperClass="true"
	accessors       ="true"
{

	property name="id" fieldtype="id" ormtype="string";

}
