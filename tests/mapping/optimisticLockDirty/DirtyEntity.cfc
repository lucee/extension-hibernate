// optimistic-lock="dirty" — UPDATE WHERE includes only the changed columns.
// H7 still recognises the strategy but check it through end-to-end.
component persistent="true" table="dirty_entity" optimisticlock="dirty" dynamicupdate="true" accessors="true" {

	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="50";
	property name="age"  ormtype="integer";
}
