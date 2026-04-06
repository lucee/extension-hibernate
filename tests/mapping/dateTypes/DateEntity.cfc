component persistent="true" table="DateEntity" accessors="true" {

	property name="id"             fieldtype="id" ormtype="string";
	property name="dateValue"      ormtype="date";
	property name="timeValue"      ormtype="time";
	property name="timestampValue" ormtype="timestamp";

}
