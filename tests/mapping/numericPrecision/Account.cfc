component persistent="true" table="NP_Account" accessors="true" {

	property name="id"      fieldtype="id" ormtype="string";
	property name="balance" ormtype="big_decimal" precision="12" scale="4";
	property name="rate"    ormtype="double"      precision="8";

}
