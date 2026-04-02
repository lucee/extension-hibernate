/**
 * OOE-15 test entity: ID with generator="native" and NO explicit ormtype.
 *
 * The omitted ormtype is the point — type resolution must fall through
 * prop.getType() ("any" on modern Lucee, "numeric" on 4.5) to the
 * generator default of "integer", not map to "double".
 */
component persistent="true" accessors="true" table="OOE15_NativeId" {

	property name="id" fieldtype="id" generator="native" notnull="true" default="0" unsavedvalue="0";
	property name="name" ormtype="string";

}
