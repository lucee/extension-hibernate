component persistent="true" table="cv_invalid_parent" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";

	// `delete_orphan` (underscore) was advertised by the dead HibernateCaster.cascade
	// method but never accepted by Hibernate's parser. The new HBMCreator validator
	// rejects it pre-Hibernate with an "Invalid value [delete_orphan]" error.
	property name="children"
		fieldtype="one-to-many"
		cfc="InvalidChild"
		fkcolumn="parent_id"
		cascade="delete_orphan"
		inverse="false";
}
