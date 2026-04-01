component persistent="true" accessors="true" {

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
	property name="textVal"       ormtype="text";
	property name="yesNoVal"      ormtype="yes_no";
	property name="trueFalseVal"  ormtype="true_false";

}
