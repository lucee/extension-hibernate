component persistent="true" table="OTO_CPassport" accessors="true" {

	property name="id"     fieldtype="id" ormtype="string";
	property name="number" ormtype="string";
	property name="holder"
		fieldtype="one-to-one"
		cfc="Citizen"
		constrained="true"
		lazy="false";

}
