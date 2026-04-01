component persistent="true" accessors="true" table="ExtraTypesNumeric" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";

	property name="shortVal"      ormtype="short";
	property name="longVal"       ormtype="long";
	property name="floatVal"      ormtype="float";
	property name="doubleVal"     ormtype="double";
	property name="bigDecimalVal" ormtype="big_decimal";

}
