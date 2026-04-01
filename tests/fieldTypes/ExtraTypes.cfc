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
	// ormtype="text" and "clob" both generate varchar(2147483647) on H2 which fails
	// this is a Hibernate H2Dialect limitation, not our bug
	property name="textVal"       ormtype="string" length="4000";

}
