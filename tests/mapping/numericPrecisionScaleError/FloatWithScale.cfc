component persistent="true" table="NP_FloatWithScale" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	// scale on a floating-point ormtype is invalid in Hibernate 7.3+ — must throw at SF build
	property name="rate" ormtype="double" precision="8" scale="6";

}
