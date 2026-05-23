// LDEV-6340 repro — `mappedSuperClass="true"` *alone* (no `persistent="false"`)
// is the canonical JPA shape. Properties get inlined into children via
// HBMCreator.loadForeignCFC; this CFC itself never appears as an <hibernate-mapping/class>.
component
	mappedSuperClass="true"
	accessors       ="true"
{

	property
		name   ="createdAt"
		ormtype="timestamp"
		insert ="true"
		update ="false";

}
