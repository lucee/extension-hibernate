component persistent="true" table="evict_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// H5 supported `cascade="evict"` (CascadeStyles.EVICT). H6 removed it. Probe
	// whether SF builds.
	property name="children"
		fieldtype="one-to-many"
		cfc="EvictChild"
		fkcolumn="parent_id"
		cascade="evict"
		inverse="false";
}
